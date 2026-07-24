'use client';

import React, { useState } from 'react';
import { X, Wrench, CheckCircle2, AlertTriangle, Clock, XCircle } from 'lucide-react';
import { WorkOrder, SparePartItem } from '../types';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { Card, CardContent } from '@/components/ui/card';

interface WorkOrderDetailModalProps {
  workOrder: WorkOrder | null;
  isOpen: boolean;
  onClose: () => void;
  costApprovalThreshold?: number;
  onClaimWorkOrder: (woId: string) => void;
  onCompleteWorkOrder: (woId: string, usedParts: SparePartItem[]) => void;
  onAddSparePartToWO: (woId: string, part: SparePartItem) => void;
  onCancelWorkOrder?: (woId: string, reason: string) => void;
}

export const WorkOrderDetailModal: React.FC<WorkOrderDetailModalProps> = ({
  workOrder,
  isOpen,
  onClose,
  costApprovalThreshold = 2000000,
  onClaimWorkOrder,
  onCompleteWorkOrder,
  onAddSparePartToWO,
  onCancelWorkOrder,
}) => {
  const [partName, setPartName] = useState('');
  const [partQty, setPartQty] = useState('1');
  const [partUnitPrice, setPartUnitPrice] = useState('500000');
  const [showAddPartForm, setShowAddPartForm] = useState(false);
  const [showCancelForm, setShowCancelForm] = useState(false);
  const [cancellationReasonInput, setCancellationReasonInput] = useState('');
  const [raceConditionError, setRaceConditionError] = useState(false);

  if (!isOpen || !workOrder) return null;

  const handleAddPart = (e: React.FormEvent) => {
    e.preventDefault();
    if (!partName.trim()) return;

    const qty = parseInt(partQty) || 1;
    const price = parseInt(partUnitPrice) || 0;
    const total = qty * price;
    const requiresAppr = total >= costApprovalThreshold;

    const newPart: SparePartItem = {
      id: `sp-${Date.now()}`,
      name: partName.trim(),
      quantity: qty,
      unitPrice: price,
      totalCost: total,
      requiresApproval: requiresAppr,
      status: requiresAppr ? 'PENDING' : 'APPROVED',
    };

    onAddSparePartToWO(workOrder.id, newPart);
    setPartName('');
    setPartQty('1');
    setPartUnitPrice('500000');
    setShowAddPartForm(false);
  };

  const handleClaim = () => {
    // Race condition simulation check (US-04)
    if (workOrder.status !== 'PENDING') {
      setRaceConditionError(true);
      return;
    }
    onClaimWorkOrder(workOrder.id);
    onClose();
  };

  const handleConfirmCancel = (e: React.FormEvent) => {
    e.preventDefault();
    if (!cancellationReasonInput.trim()) {
      alert('Vui lòng nhập lý do hủy phiếu!');
      return;
    }
    if (onCancelWorkOrder) {
      onCancelWorkOrder(workOrder.id, cancellationReasonInput.trim());
    }
    setShowCancelForm(false);
    setCancellationReasonInput('');
    onClose();
  };

  const getSeverityBadge = (severity: string) => {
    switch (severity) {
      case 'CRITICAL':
        return <Badge variant="destructive">🔴 CRITICAL</Badge>;
      case 'HIGH':
        return <Badge variant="maintenance">🟠 HIGH</Badge>;
      case 'MEDIUM':
        return <Badge variant="secondary">🟡 MEDIUM</Badge>;
      default:
        return <Badge variant="outline">🟢 LOW</Badge>;
    }
  };

  return (
    <div className="fixed inset-0 z-50 flex items-end sm:items-center justify-center bg-slate-900/60 backdrop-blur-sm p-0 sm:p-4">
      <div className="w-full max-w-md bg-white border border-slate-200 rounded-t-2xl sm:rounded-2xl overflow-hidden shadow-2xl max-h-[90vh] flex flex-col animate-in slide-in-from-bottom duration-300">
        
        {/* Header */}
        <div className="p-4 border-b border-slate-100 bg-slate-50 flex items-center justify-between">
          <div>
            <div className="flex items-center gap-2 mb-0.5">
              <span className="px-2 py-0.5 rounded bg-rose-100 text-rose-800 font-mono text-xs font-extrabold border border-rose-200">
                {workOrder.code}
              </span>
              {getSeverityBadge(workOrder.severity)}
            </div>
            <h2 className="font-extrabold text-slate-900 text-base">Chi Tiết Phiếu Báo Lỗi SOS</h2>
          </div>
          <button
            onClick={onClose}
            className="p-1.5 rounded-full text-slate-400 hover:text-slate-700 hover:bg-slate-200/60 transition"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* Scrollable Modal Content */}
        <div className="p-4 overflow-y-auto flex-1 space-y-3.5">
          
          {/* Race Condition Error Banner (US-04) */}
          {raceConditionError && (
            <div className="p-3 rounded-xl bg-rose-100 border border-rose-300 text-rose-900 text-xs font-extrabold flex items-center gap-2 animate-in shake">
              <AlertTriangle className="w-5 h-5 text-rose-600 shrink-0" />
              <span>Phiếu đã được tiếp nhận bởi kỹ sư khác! Bạn không thể nhận trùng.</span>
            </div>
          )}

          {/* Machine & Reporter Summary Card */}
          <Card className="bg-slate-50/50">
            <CardContent className="p-3.5 space-y-2 text-xs">
              <div className="flex items-center justify-between border-b border-slate-200 pb-2">
                <div>
                  <span className="text-[10px] text-slate-400 font-bold uppercase block">Thiết Bị Sự Cố</span>
                  <span className="font-extrabold text-slate-900 text-sm">{workOrder.machineName}</span>
                </div>
                <span className="font-mono font-bold px-2 py-0.5 rounded bg-emerald-100 text-emerald-800 border border-emerald-200">
                  {workOrder.machineCode}
                </span>
              </div>

              <div className="grid grid-cols-2 gap-2 text-[11px] pt-1">
                <div>
                  <span className="text-slate-500">Báo bởi:</span> <strong className="text-slate-800">{workOrder.reporterName}</strong>
                </div>
                <div>
                  <span className="text-slate-500">Thời gian:</span> <strong className="text-slate-800">{workOrder.downtimeStart}</strong>
                </div>
              </div>

              {workOrder.assigneeName && (
                <div className="text-[11px] text-cyan-800 bg-cyan-50 p-2 rounded-lg border border-cyan-200 font-medium">
                  Kỹ sư tiếp nhận: <strong>{workOrder.assigneeName}</strong>
                </div>
              )}
            </CardContent>
          </Card>

          {/* Rejection Alert Banner if status is REJECTED */}
          {workOrder.status === 'REJECTED' && workOrder.rejectionReason && (
            <div className="p-3 rounded-2xl bg-rose-50 border border-rose-300 text-rose-900 text-xs font-medium space-y-1">
              <div className="font-extrabold text-rose-700">
                Quản đốc đã từ chối nghiệm thu!
              </div>
              <p className="text-[11px] leading-snug">
                Lý do: <strong>"{workOrder.rejectionReason}"</strong>. Vui lòng kiểm tra kỹ thuật và gửi nghiệm thu lại sau khi sửa xong.
              </p>
            </div>
          )}

          {/* Failure Description */}
          <div>
            <h4 className="text-xs font-extrabold text-slate-800 uppercase tracking-wider mb-1">
              Mô Tả Chi Tiết Sự Cố:
            </h4>
            <div className="p-3 rounded-2xl bg-slate-50 border border-slate-200 text-xs text-slate-800 leading-relaxed font-medium">
              {workOrder.description}
            </div>
          </div>

          {/* Failure Photo Attachment */}
          {workOrder.imageUrl && (
            <div>
              <h4 className="text-xs font-extrabold text-slate-800 uppercase tracking-wider mb-1">
                Ảnh Minh Chứng Lỗi Hiện Trường:
              </h4>
              <div className="relative rounded-2xl overflow-hidden border border-slate-200 bg-slate-900">
                <img
                  src={workOrder.imageUrl}
                  alt="Ảnh sự cố"
                  className="w-full h-44 object-cover hover:scale-105 transition-transform duration-300"
                />
              </div>
            </div>
          )}

          {/* Used Spare Parts Section (Feature 6 & 10) */}
          <div>
            <div className="flex items-center justify-between mb-1.5">
              <h4 className="text-xs font-extrabold text-slate-800 uppercase tracking-wider">
                Linh Kiện Đã Khai Báo:
              </h4>
              {workOrder.status !== 'APPROVED' && workOrder.status !== 'CANCELLED' && (
                <button
                  type="button"
                  onClick={() => setShowAddPartForm(!showAddPartForm)}
                  className="text-[11px] font-bold text-cyan-700 hover:underline"
                >
                  + Khai báo thêm phụ tùng
                </button>
              )}
            </div>

            {/* Form for adding spare part */}
            {showAddPartForm && (
              <form onSubmit={handleAddPart} className="p-3 rounded-2xl bg-slate-50 border border-cyan-300 space-y-2 mb-2">
                <div className="text-xs font-bold text-slate-800">Thêm Vật Tư / Phụ Tùng Thay Thế</div>
                <input
                  type="text"
                  placeholder="Tên phụ tùng (e.g. Vòng bi Spindle 7014C)"
                  value={partName}
                  onChange={(e) => setPartName(e.target.value)}
                  className="w-full bg-white border border-slate-300 rounded-xl px-3 py-1.5 text-xs text-slate-900 focus:outline-none focus:border-cyan-500 font-medium"
                  required
                />
                <div className="flex gap-2">
                  <input
                    type="number"
                    min="1"
                    placeholder="SL"
                    value={partQty}
                    onChange={(e) => setPartQty(e.target.value)}
                    className="w-16 bg-white border border-slate-300 rounded-xl px-2 py-1.5 text-xs text-center font-bold"
                  />
                  <input
                    type="number"
                    step="50000"
                    placeholder="Đơn giá (VND)"
                    value={partUnitPrice}
                    onChange={(e) => setPartUnitPrice(e.target.value)}
                    className="flex-1 bg-white border border-slate-300 rounded-xl px-3 py-1.5 text-xs font-mono font-semibold"
                  />
                </div>

                <div className="flex items-center justify-between pt-1">
                  <span className="text-[10px] text-slate-500">
                    Duyệt Quản đốc nếu &gt; {(costApprovalThreshold / 1000000).toFixed(1)}Trđ
                  </span>
                  <div className="flex gap-1">
                    <Button type="button" size="sm" variant="outline" onClick={() => setShowAddPartForm(false)}>
                      Hủy
                    </Button>
                    <Button type="submit" size="sm" variant="cyan">
                      Lưu Vật Tư
                    </Button>
                  </div>
                </div>
              </form>
            )}

            {/* List of used parts */}
            {workOrder.usedSpareParts && workOrder.usedSpareParts.length > 0 ? (
              <div className="space-y-1.5">
                {workOrder.usedSpareParts.map((sp) => (
                  <div key={sp.id} className="p-2.5 rounded-xl bg-slate-50 border border-slate-200 flex items-center justify-between text-xs">
                    <div>
                      <span className="font-bold text-slate-900 block">{sp.name}</span>
                      <span className="text-[11px] text-slate-500 font-mono">
                        x{sp.quantity} cái • {sp.totalCost.toLocaleString('vi-VN')} VNĐ
                      </span>
                    </div>

                    <div>
                      {sp.requiresApproval ? (
                        <Badge variant={sp.status === 'APPROVED' ? 'active' : 'destructive'}>
                          {sp.status === 'APPROVED' ? 'Đã Duyệt' : 'Chờ QĐ Duyệt'}
                        </Badge>
                      ) : (
                        <Badge variant="secondary">Tự Động</Badge>
                      )}
                    </div>
                  </div>
                ))}
              </div>
            ) : (
              <div className="text-[11px] text-slate-400 italic p-2 border border-dashed border-slate-200 rounded-xl text-center">
                Chưa khai báo linh kiện thay thế cho phiếu này.
              </div>
            )}
          </div>

          {/* Cancellation Form Modal (US-13) */}
          {showCancelForm && (
            <form onSubmit={handleConfirmCancel} className="p-3.5 rounded-2xl bg-rose-50 border border-rose-300 space-y-2.5">
              <div className="text-xs font-extrabold text-rose-800 flex items-center gap-1.5">
                <XCircle className="w-4 h-4 text-rose-600" /> Hủy Phiếu SOS Đã Báo Nhầm (US-13)
              </div>
              <p className="text-[11px] text-rose-700">Trạng thái máy sẽ tự động quay về ACTIVE sau khi hủy.</p>
              
              <textarea
                rows={2}
                required
                placeholder="Nhập lý do hủy phiếu (e.g. Thao tác nhầm, sự cố nhẹ đã tự khắc phục...)"
                value={cancellationReasonInput}
                onChange={(e) => setCancellationReasonInput(e.target.value)}
                className="w-full bg-white border border-rose-300 rounded-xl p-2.5 text-xs text-slate-900 focus:outline-none focus:border-rose-500"
              />

              <div className="flex gap-2">
                <Button type="button" size="sm" variant="outline" onClick={() => setShowCancelForm(false)} className="flex-1">
                  Quay Lại
                </Button>
                <Button type="submit" size="sm" variant="destructive" className="flex-1 font-bold">
                  Xác Nhận Hủy Phiếu
                </Button>
              </div>
            </form>
          )}

        </div>

        {/* Footer Actions */}
        <div className="p-4 border-t border-slate-100 bg-white space-y-2">
          {workOrder.status === 'PENDING' && !showCancelForm && (
            <div className="space-y-2">
              <Button
                variant="cyan"
                size="lg"
                onClick={handleClaim}
                className="w-full h-11 text-xs font-black"
              >
                <Wrench className="w-4 h-4" /> Bấm Tiếp Nhận Sửa Chữa Ngay
              </Button>

              <Button
                variant="outline"
                size="sm"
                onClick={() => setShowCancelForm(true)}
                className="w-full h-9 text-xs font-bold text-rose-700 border-rose-200 hover:bg-rose-50"
              >
                <XCircle className="w-4 h-4 text-rose-600" /> Hủy Phiếu SOS Báo Nhầm (US-13)
              </Button>
            </div>
          )}

          {(workOrder.status === 'IN_PROGRESS' || workOrder.status === 'REJECTED') && (
            <Button
              variant="default"
              size="lg"
              onClick={() => {
                onCompleteWorkOrder(workOrder.id, workOrder.usedSpareParts || []);
                onClose();
              }}
              className="w-full h-11 text-xs font-black"
            >
              <CheckCircle2 className="w-4 h-4" /> Hoàn Thành & Gửi Quản Đốc Nghiệm Thu
            </Button>
          )}

          {workOrder.status === 'COMPLETED' && (
            <div className="p-3 rounded-xl bg-amber-50 border border-amber-200 text-amber-900 text-xs font-bold text-center">
              Đã hoàn thành sửa chữa — Đang chờ Quản đốc ký nghiệm thu!
            </div>
          )}

          {workOrder.status === 'APPROVED' && (
            <div className="p-3 rounded-xl bg-emerald-50 border border-emerald-200 text-emerald-900 text-xs font-bold text-center">
              Đã được Quản đốc ký nghiệm thu & bàn giao về Active!
            </div>
          )}

          {workOrder.status === 'CANCELLED' && (
            <div className="p-3 rounded-xl bg-slate-100 border border-slate-300 text-slate-700 text-xs font-bold text-center">
              Phiếu đã bị HỦY (Lý do: {workOrder.cancellationReason || 'Báo nhầm'})
            </div>
          )}
        </div>

      </div>
    </div>
  );
};
