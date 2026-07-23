'use client';

import React, { useState } from 'react';
import { X, CheckSquare, Square, Camera, PackagePlus, CheckCircle2, Wrench, AlertCircle, AlertTriangle } from 'lucide-react';
import { PMChecklist, PMChecklistItem, SparePartItem } from '../types';
import { Button } from '@/components/ui/button';

interface PMChecklistModalProps {
  checklist: PMChecklist | null;
  isOpen: boolean;
  onClose: () => void;
  costApprovalThreshold?: number;
  onCompletePM: (
    pmId: string,
    items: PMChecklistItem[],
    spareParts: SparePartItem[]
  ) => void;
}

export const PMChecklistModal: React.FC<PMChecklistModalProps> = ({
  checklist,
  isOpen,
  onClose,
  costApprovalThreshold = 2000000,
  onCompletePM,
}) => {
  const [items, setItems] = useState<PMChecklistItem[]>([]);
  const [partName, setPartName] = useState('');
  const [partQty, setPartQty] = useState('1');
  const [partUnitPrice, setPartUnitPrice] = useState('500000');
  const [spareParts, setSpareParts] = useState<SparePartItem[]>([]);

  React.useEffect(() => {
    if (checklist) {
      setItems([...checklist.items]);
      setSpareParts([]);
    }
  }, [checklist]);

  if (!isOpen || !checklist) return null;

  const toggleItem = (itemId: string) => {
    setItems((prev) =>
      prev.map((it) => (it.id === itemId ? { ...it, isChecked: !it.isChecked } : it))
    );
  };

  const simulatePhotoUpload = (itemId: string) => {
    setItems((prev) =>
      prev.map((it) =>
        it.id === itemId
          ? {
              ...it,
              photoUrl: 'https://images.unsplash.com/photo-1504917595217-d4dc5ebe6122?w=500&auto=format&fit=crop&q=80',
            }
          : it
      )
    );
  };

  const handleAddSparePart = () => {
    if (partName.trim()) {
      const qty = parseInt(partQty) || 1;
      const uPrice = parseInt(partUnitPrice) || 0;
      const total = qty * uPrice;
      const requiresAppr = total >= costApprovalThreshold;

      const newPart: SparePartItem = {
        id: `sp-${Date.now()}`,
        name: partName.trim(),
        quantity: qty,
        unitPrice: uPrice,
        totalCost: total,
        requiresApproval: requiresAppr,
        status: requiresAppr ? 'PENDING' : 'APPROVED',
      };

      setSpareParts((prev) => [...prev, newPart]);
      setPartName('');
      setPartQty('1');
      setPartUnitPrice('500000');
    }
  };

  const allMandatoryCompleted = items.every(
    (it) => (!it.isRequiredPhoto || (it.isRequiredPhoto && it.photoUrl)) && it.isChecked
  );

  const handleComplete = () => {
    if (!allMandatoryCompleted) {
      alert('Vui lòng tích hoàn thành 100% checklist và chụp ảnh minh chứng cho các hạng mục bắt buộc!');
      return;
    }

    onCompletePM(checklist.id, items, spareParts);
    onClose();
  };

  return (
    <div className="fixed inset-0 z-50 flex items-end sm:items-center justify-center bg-slate-900/60 backdrop-blur-sm p-0 sm:p-4">
      <div className="w-full max-w-md bg-white border border-slate-200 rounded-t-3xl sm:rounded-3xl overflow-hidden shadow-2xl max-h-[90vh] flex flex-col animate-in slide-in-from-bottom duration-300">
        
        {/* Header */}
        <div className="p-4 border-b border-slate-100 bg-slate-50 flex items-center justify-between">
          <div>
            <div className="flex items-center gap-2 mb-0.5">
              <span className="px-2 py-0.5 rounded bg-amber-100 text-amber-800 font-mono text-xs font-extrabold border border-amber-200">
                {checklist.code}
              </span>
              <span className="text-xs font-semibold text-slate-500">Mốc {checklist.scheduledHours}h</span>
            </div>
            <h2 className="font-extrabold text-slate-900 text-base">{checklist.machineName}</h2>
          </div>
          <button
            onClick={onClose}
            className="p-1.5 rounded-full text-slate-400 hover:text-slate-700 hover:bg-slate-200/60 transition"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* Body content */}
        <div className="p-4 overflow-y-auto flex-1 space-y-4">
          
          {/* Checklist Task Items */}
          <div>
            <h3 className="text-xs font-extrabold uppercase tracking-wider text-slate-500 mb-2.5 flex items-center gap-1.5">
              <Wrench className="w-4 h-4 text-emerald-600" />
              Danh Sách Kiểm Tra Bắt Buộc (Checklist):
            </h3>

            <div className="space-y-2">
              {items.map((item) => (
                <div
                  key={item.id}
                  className={`p-3 rounded-2xl border transition ${
                    item.isChecked
                      ? 'bg-emerald-50/50 border-emerald-200'
                      : 'bg-slate-50 border-slate-200'
                  }`}
                >
                  <div className="flex items-start gap-2.5">
                    <button
                      type="button"
                      onClick={() => toggleItem(item.id)}
                      className="mt-0.5 text-emerald-600 hover:scale-110 transition"
                    >
                      {item.isChecked ? (
                        <CheckSquare className="w-5 h-5 fill-emerald-100 text-emerald-600" />
                      ) : (
                        <Square className="w-5 h-5 text-slate-400" />
                      )}
                    </button>
                    <div className="flex-1">
                      <p className={`text-xs ${item.isChecked ? 'line-through text-slate-400 font-medium' : 'text-slate-800 font-bold'}`}>
                        {item.taskDescription}
                      </p>

                      {/* Photo requirement badge / Upload */}
                      {item.isRequiredPhoto && (
                        <div className="mt-2 flex items-center justify-between text-[11px]">
                          <span className="text-amber-700 font-bold flex items-center gap-1">
                            <AlertCircle className="w-3.5 h-3.5" /> Yêu cầu ảnh minh chứng
                          </span>

                          {item.photoUrl ? (
                            <span className="text-emerald-700 font-extrabold flex items-center gap-1">
                              <CheckCircle2 className="w-3.5 h-3.5" /> Đã đính kèm ảnh
                            </span>
                          ) : (
                            <button
                              type="button"
                              onClick={() => simulatePhotoUpload(item.id)}
                              className="px-2.5 py-1 rounded-lg bg-white hover:bg-slate-100 text-slate-700 border border-slate-300 font-bold flex items-center gap-1 transition shadow-xs"
                            >
                              <Camera className="w-3 h-3 text-amber-600" /> Chụp ảnh
                            </button>
                          )}
                        </div>
                      )}
                    </div>
                  </div>
                </div>
              ))}
            </div>
          </div>

          {/* Spare Parts Logging (US-06, US-07, Feature 6 & 12) */}
          <div className="pt-3 border-t border-slate-100">
            <h3 className="text-xs font-extrabold uppercase tracking-wider text-slate-500 mb-2 flex items-center justify-between">
              <span className="flex items-center gap-1.5">
                <PackagePlus className="w-4 h-4 text-cyan-600" />
                Khai Báo Linh Kiện/Vật Tư Thay Thế:
              </span>
              <span className="text-[10px] text-slate-400 font-medium">Duyệt chi phí &gt; {(costApprovalThreshold / 1000000).toFixed(1)}Tr</span>
            </h3>

            <div className="space-y-2 mb-2">
              <input
                type="text"
                placeholder="Tên linh kiện (e.g. Vòng bi cao tốc 7014C)"
                value={partName}
                onChange={(e) => setPartName(e.target.value)}
                className="w-full bg-slate-50 border border-slate-200 rounded-xl px-3 py-1.5 text-xs text-slate-900 placeholder-slate-400 focus:outline-none focus:border-cyan-500 focus:bg-white"
              />

              <div className="flex gap-2">
                <input
                  type="number"
                  min="1"
                  placeholder="SL"
                  value={partQty}
                  onChange={(e) => setPartQty(e.target.value)}
                  className="w-16 bg-slate-50 border border-slate-200 rounded-xl px-2 py-1.5 text-xs text-center font-bold text-slate-900 focus:outline-none"
                />
                <input
                  type="number"
                  step="50000"
                  placeholder="Đơn giá (VND)"
                  value={partUnitPrice}
                  onChange={(e) => setPartUnitPrice(e.target.value)}
                  className="flex-1 bg-slate-50 border border-slate-200 rounded-xl px-3 py-1.5 text-xs text-slate-900 font-mono focus:outline-none"
                />
                <Button type="button" variant="cyan" size="sm" onClick={handleAddSparePart}>
                  + Thêm
                </Button>
              </div>
            </div>

            {spareParts.length > 0 && (
              <div className="space-y-1.5">
                {spareParts.map((sp) => (
                  <div key={sp.id} className="p-2.5 rounded-xl bg-slate-50 border border-slate-200 flex items-center justify-between text-xs">
                    <div>
                      <span className="font-bold text-slate-800 block">{sp.name}</span>
                      <span className="text-[11px] text-slate-500 font-mono">
                        {sp.quantity} cái x {sp.unitPrice.toLocaleString('vi-VN')} = {sp.totalCost.toLocaleString('vi-VN')}đ
                      </span>
                    </div>

                    <div>
                      {sp.requiresApproval ? (
                        <span className="px-2 py-0.5 rounded text-[10px] font-extrabold bg-rose-100 text-rose-800 border border-rose-200 flex items-center gap-1">
                          <AlertTriangle className="w-3 h-3" /> Cần QĐ Duyệt
                        </span>
                      ) : (
                        <span className="px-2 py-0.5 rounded text-[10px] font-extrabold bg-emerald-100 text-emerald-800 border border-emerald-200">
                          Tự động ghi nhận
                        </span>
                      )}
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>

        </div>

        {/* Footer Action */}
        <div className="p-4 border-t border-slate-100 bg-white">
          <Button
            type="button"
            variant="default"
            disabled={!allMandatoryCompleted}
            onClick={handleComplete}
            className="w-full h-11 text-xs font-black"
          >
            <CheckCircle2 className="w-5 h-5" /> Hoàn Thành PM & Gửi Nghiệm Thu
          </Button>
        </div>

      </div>
    </div>
  );
};
