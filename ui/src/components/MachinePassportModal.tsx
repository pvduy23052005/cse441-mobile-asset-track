'use client';

import React, { useState, useEffect } from 'react';
import { X, Clock, AlertTriangle, Cpu, Wrench, ChevronDown, CheckCircle2, PlusCircle, Calendar, ShieldCheck, History, Plus, Edit2, Trash2, Save } from 'lucide-react';
import { Machine, WorkOrder, PMChecklist } from '../types';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';

interface MachinePassportModalProps {
  machine: Machine | null;
  isOpen: boolean;
  onClose: () => void;
  onUpdateHours: (machineId: string, newHours: number, shift: 'START_SHIFT' | 'END_SHIFT') => void;
  onOpenSOS: (machine: Machine) => void;
  pastWorkOrders?: WorkOrder[];
  pastChecklists?: PMChecklist[];
  userRole?: 'OPERATOR' | 'ME_ENGINEER' | 'SUPERVISOR';
  onUpdateTroubleshooting?: (machineId: string, updatedTroubleshooting: Array<{ issue: string; solution: string }>) => void;
}

export const MachinePassportModal: React.FC<MachinePassportModalProps> = ({
  machine,
  isOpen,
  onClose,
  onUpdateHours,
  onOpenSOS,
  pastWorkOrders = [],
  pastChecklists = [],
  userRole = 'OPERATOR',
  onUpdateTroubleshooting,
}) => {
  const [activeTab, setActiveTab] = useState<'SPECS' | 'TROUBLESHOOT' | 'HISTORY'>('SPECS');
  const [showHoursPopup, setShowHoursPopup] = useState(false);
  const [inputHours, setInputHours] = useState('');
  const [shift, setShift] = useState<'START_SHIFT' | 'END_SHIFT'>('END_SHIFT');
  const [openTroubleshootIdx, setOpenTroubleshootIdx] = useState<number | null>(0);

  // States cho việc Thêm/Sửa Cẩm nang lỗi nhanh
  const [isEditingTrouble, setIsEditingTrouble] = useState(false);
  const [troubleList, setTroubleList] = useState<Array<{ issue: string; solution: string }>>([]);

  useEffect(() => {
    if (machine) {
      setTroubleList(machine.quickTroubleshooting || []);
    }
  }, [machine]);

  if (!isOpen || !machine) return null;

  const handleHoursSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    const val = parseFloat(inputHours);
    if (!isNaN(val) && val > machine.runningHours) {
      onUpdateHours(machine.id, val, shift);
      setShowHoursPopup(false);
      setInputHours('');
    } else {
      alert(`Chỉ số máy chạy mới phải là số LỚN HƠN chỉ số lần trước (${machine.runningHours})`);
    }
  };

  const handleAddTroubleItem = () => {
    setTroubleList([...troubleList, { issue: '', solution: '' }]);
  };

  const handleRemoveTroubleItem = (idx: number) => {
    setTroubleList(troubleList.filter((_, i) => i !== idx));
  };

  const handleTroubleChange = (idx: number, field: 'issue' | 'solution', val: string) => {
    const updated = [...troubleList];
    updated[idx][field] = val;
    setTroubleList(updated);
  };

  const handleSaveTroubleshooting = () => {
    const valid = troubleList.filter((t) => t.issue.trim() !== '' || t.solution.trim() !== '');
    machine.quickTroubleshooting = valid;
    if (onUpdateTroubleshooting) {
      onUpdateTroubleshooting(machine.id, valid);
    }
    setIsEditingTrouble(false);
    alert('✅ Đã cập nhật Cẩm nang xử lý lỗi nhanh thành công!');
  };

  const remainingHours = machine.nextMaintenanceHours - machine.runningHours;
  const isNearMaintenance = remainingHours > 0 && remainingHours <= machine.nextMaintenanceHours * 0.1;
  const isOverdue = remainingHours <= 0;

  const canEditTroubleshoot = userRole === 'SUPERVISOR' || userRole === 'ME_ENGINEER';

  const getStatusBadge = (status: string) => {
    switch (status) {
      case 'ACTIVE':
        return <Badge variant="active">● HOẠT ĐỘNG</Badge>;
      case 'REPAIRING':
        return <Badge variant="repairing">● SỬA CHỮA (SOS)</Badge>;
      case 'MAINTENANCE':
        return <Badge variant="maintenance">● BẢO TRÌ PM</Badge>;
      default:
        return <Badge variant="secondary">● NGỪNG</Badge>;
    }
  };

  // Dynamic history calculation
  const machineWOs = pastWorkOrders.filter((wo) => wo.machineId === machine.id || wo.machineCode === machine.code);
  const machinePMs = pastChecklists.filter((pm) => pm.machineId === machine.id || pm.machineCode === machine.code);

  return (
    <div className="fixed inset-0 z-50 flex items-end sm:items-center justify-center bg-slate-900/60 backdrop-blur-sm p-0 sm:p-4">
      <div className="w-full max-w-md bg-white border border-slate-200 rounded-t-2xl sm:rounded-2xl max-h-[90vh] flex flex-col shadow-2xl animate-in slide-in-from-bottom duration-300">
        
        {/* Header */}
        <div className="p-4 border-b border-slate-100 bg-slate-50/60 flex items-start justify-between">
          <div>
            <div className="flex items-center gap-2 mb-1">
              <span className="px-2 py-0.5 rounded bg-emerald-100 text-emerald-800 font-mono text-xs font-extrabold border border-emerald-200">
                {machine.code}
              </span>
              {getStatusBadge(machine.status)}
            </div>
            <h2 className="text-lg font-extrabold text-slate-900">{machine.name}</h2>
            <p className="text-xs text-slate-500 font-medium">{machine.location}</p>
          </div>
          <button
            onClick={onClose}
            type="button"
            className="p-1.5 rounded-full text-slate-400 hover:text-slate-700 hover:bg-slate-200/60 transition"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* Running hours / Km quick bar */}
        <div className="mx-3.5 my-2.5 p-3 rounded-xl bg-gradient-to-r from-emerald-50 to-teal-50 border border-emerald-200/80 flex items-center justify-between shadow-xs">
          <div>
            <div className="text-[11px] text-slate-500 uppercase font-bold tracking-wider">
              {machine.unitLabel || 'Tổng Chỉ Số Vận Hành'}
            </div>
            <div className="text-2xl font-black font-mono text-emerald-700 flex items-baseline gap-1">
              {machine.runningHours.toLocaleString('vi-VN')} <span className="text-xs text-slate-500 font-normal">{machine.trackingUnit === 'KM' ? 'Km' : 'Giờ'}</span>
            </div>
          </div>
          {userRole === 'OPERATOR' && (
            <Button
              size="sm"
              variant="default"
              onClick={() => setShowHoursPopup(true)}
              className="h-8 rounded-lg font-bold"
            >
              <PlusCircle className="w-3.5 h-3.5" /> + Nhập Chỉ Số
            </Button>
          )}
        </div>

        {/* Hours Update Popup Form */}
        {showHoursPopup && (
          <form onSubmit={handleHoursSubmit} className="mx-5 mb-3 p-3 rounded-2xl bg-slate-50 border border-emerald-300 space-y-2">
            <div className="text-xs font-bold text-slate-800 flex items-center justify-between">
              <span>Cập Nhật Chỉ Số Vận Hành Hiện Tại</span>
              <span className="text-[11px] text-slate-500 font-mono">Trước: {machine.runningHours}{machine.trackingUnit === 'KM' ? 'km' : 'h'}</span>
            </div>

            <div className="flex gap-2">
              <input
                type="number"
                step="0.1"
                placeholder={`Chỉ số mới (> ${machine.runningHours})`}
                value={inputHours}
                onChange={(e) => setInputHours(e.target.value)}
                className="flex-1 bg-white border border-slate-300 rounded-xl px-3 py-1.5 text-xs text-slate-900 font-bold focus:outline-none focus:border-emerald-500"
                required
              />
              <Button type="submit" size="sm" variant="default">
                Lưu
              </Button>
              <Button type="button" size="sm" variant="secondary" onClick={() => setShowHoursPopup(false)}>
                Hủy
              </Button>
            </div>

            {/* Shift Selector */}
            <div className="flex items-center gap-4 text-xs pt-1">
              <span className="text-slate-600 font-medium">Thời điểm ca:</span>
              <label className="flex items-center gap-1 cursor-pointer font-bold text-slate-700">
                <input
                  type="radio"
                  name="shift"
                  checked={shift === 'START_SHIFT'}
                  onChange={() => setShift('START_SHIFT')}
                />
                Đầu Ca
              </label>
              <label className="flex items-center gap-1 cursor-pointer font-bold text-slate-700">
                <input
                  type="radio"
                  name="shift"
                  checked={shift === 'END_SHIFT'}
                  onChange={() => setShift('END_SHIFT')}
                />
                Cuối Ca
              </label>
            </div>
          </form>
        )}

        {/* Navigation Tabs */}
        <div className="px-5 border-b border-slate-100 flex gap-4">
          <button
            onClick={() => setActiveTab('SPECS')}
            type="button"
            className={`pb-2.5 text-xs font-extrabold border-b-2 transition ${
              activeTab === 'SPECS'
                ? 'border-emerald-600 text-emerald-700'
                : 'border-transparent text-slate-400 hover:text-slate-700'
            }`}
          >
            Thông Số Kỹ Thuật
          </button>
          <button
            onClick={() => setActiveTab('TROUBLESHOOT')}
            type="button"
            className={`pb-2.5 text-xs font-extrabold border-b-2 transition ${
              activeTab === 'TROUBLESHOOT'
                ? 'border-emerald-600 text-emerald-700'
                : 'border-transparent text-slate-400 hover:text-slate-700'
            }`}
          >
            Cẩm Nang Lỗi Nhanh
          </button>
          <button
            onClick={() => setActiveTab('HISTORY')}
            type="button"
            className={`pb-2.5 text-xs font-extrabold border-b-2 transition ${
              activeTab === 'HISTORY'
                ? 'border-emerald-600 text-emerald-700'
                : 'border-transparent text-slate-400 hover:text-slate-700'
            }`}
          >
            Lịch Sử Bảo Trì ({machineWOs.length + machinePMs.length || 3})
          </button>
        </div>

        {/* Tab Contents Scrollable */}
        <div className="p-5 overflow-y-auto flex-1 space-y-3">
          
          {activeTab === 'SPECS' && (
            <div className="space-y-2.5">
              <div className="grid grid-cols-2 gap-2 text-xs">
                <div className="p-3 rounded-xl bg-slate-50 border border-slate-200">
                  <span className="text-slate-500 font-medium block mb-0.5">Công Suất</span>
                  <span className="font-bold text-slate-900">{machine.specifications.power}</span>
                </div>
                <div className="p-3 rounded-xl bg-slate-50 border border-slate-200">
                  <span className="text-slate-500 font-medium block mb-0.5">Điện Áp Hoạt Động</span>
                  <span className="font-bold text-slate-900">{machine.specifications.voltage}</span>
                </div>
                <div className="p-3 rounded-xl bg-slate-50 border border-slate-200">
                  <span className="text-slate-500 font-medium block mb-0.5">Hãng Sản Xuất</span>
                  <span className="font-bold text-slate-900">{machine.specifications.manufacturer}</span>
                </div>
                <div className="p-3 rounded-xl bg-slate-50 border border-slate-200">
                  <span className="text-slate-500 font-medium block mb-0.5">Năm Sản Xuất</span>
                  <span className="font-bold text-slate-900">{machine.specifications.year}</span>
                </div>
              </div>

              {/* Maintenance ProgressBar */}
              <div className={`p-3.5 rounded-xl border mt-2 ${
                isOverdue ? 'bg-rose-50 border-rose-200' :
                isNearMaintenance ? 'bg-amber-50 border-amber-200' : 'bg-slate-50 border-slate-200'
              }`}>
                <div className="flex items-center justify-between text-xs mb-1.5">
                  <span className="text-slate-700 font-bold flex items-center gap-1">
                    Mốc bảo trì tiếp theo:
                    {isNearMaintenance && <span className="text-amber-700 text-[10px] font-bold">⚠️ Sắp đến hạn (&lt;10%)</span>}
                    {isOverdue && <span className="text-rose-700 text-[10px] font-bold">🚨 Quá hạn bảo trì!</span>}
                  </span>
                  <span className="font-mono text-emerald-700 font-extrabold">{machine.nextMaintenanceHours}{machine.trackingUnit === 'KM' ? 'km' : 'h'}</span>
                </div>
                <div className="w-full bg-slate-200 h-2 rounded-full overflow-hidden">
                  <div
                    className={`h-full rounded-full transition-all ${
                      isOverdue ? 'bg-rose-600' : isNearMaintenance ? 'bg-amber-500' : 'bg-emerald-500'
                    }`}
                    style={{ width: `${Math.min(100, (machine.runningHours / machine.nextMaintenanceHours) * 100)}%` }}
                  />
                </div>
                <div className="text-[11px] text-slate-500 mt-1">
                  Bảo trì gần nhất: {machine.lastMaintenanceDate} ({machine.lastMaintenanceHours}{machine.trackingUnit === 'KM' ? 'km' : 'h'})
                </div>
              </div>
            </div>
          )}

          {activeTab === 'TROUBLESHOOT' && (
            <div className="space-y-3">
              {/* Header bar cho tab TROUBLESHOOT: Nút Sửa/Thêm dành cho ME và Supervisor */}
              {canEditTroubleshoot && (
                <div className="flex items-center justify-between bg-amber-50 border border-amber-200 p-2.5 rounded-xl">
                  <span className="text-xs font-bold text-amber-900 flex items-center gap-1">
                    <Wrench className="w-3.5 h-3.5 text-amber-600" /> Quản lý bí kíp xử lý lỗi
                  </span>
                  {!isEditingTrouble ? (
                    <button
                      type="button"
                      onClick={() => setIsEditingTrouble(true)}
                      className="px-2.5 py-1 rounded-lg bg-amber-600 hover:bg-amber-700 text-white text-[11px] font-extrabold flex items-center gap-1 transition shadow-xs"
                    >
                      <Edit2 className="w-3 h-3" /> Sửa / Thêm Mẹo
                    </button>
                  ) : (
                    <button
                      type="button"
                      onClick={handleSaveTroubleshooting}
                      className="px-2.5 py-1 rounded-lg bg-emerald-600 hover:bg-emerald-700 text-white text-[11px] font-extrabold flex items-center gap-1 transition shadow-xs"
                    >
                      <Save className="w-3 h-3" /> Lưu Cẩm Nang
                    </button>
                  )}
                </div>
              )}

              {/* Chế độ CHỈ XEM (Read-only) */}
              {!isEditingTrouble ? (
                <div className="space-y-2">
                  {machine.quickTroubleshooting && machine.quickTroubleshooting.length > 0 ? (
                    machine.quickTroubleshooting.map((item, idx) => (
                      <div
                        key={idx}
                        className="rounded-xl bg-slate-50 border border-slate-200 overflow-hidden transition"
                      >
                        <button
                          type="button"
                          onClick={() => setOpenTroubleshootIdx(openTroubleshootIdx === idx ? null : idx)}
                          className="w-full p-3 text-left text-xs font-bold text-slate-800 flex items-center justify-between hover:bg-slate-100"
                        >
                          <span className="flex items-center gap-2 text-rose-700">
                            <AlertTriangle className="w-4 h-4 shrink-0" />
                            {item.issue}
                          </span>
                          <ChevronDown
                            className={`w-4 h-4 text-slate-400 transition-transform ${
                              openTroubleshootIdx === idx ? 'rotate-180' : ''
                            }`}
                          />
                        </button>
                        {openTroubleshootIdx === idx && (
                          <div className="px-3 pb-3 pt-1 text-xs text-slate-700 border-t border-slate-200 bg-white">
                            <span className="text-emerald-700 font-bold block mb-1">Hướng khắc phục nhanh:</span>
                            {item.solution}
                          </div>
                        )}
                      </div>
                    ))
                  ) : (
                    <div className="text-center py-6 text-slate-400 text-xs italic">
                      Chưa có mẹo xử lý lỗi nào trong cẩm nang.
                    </div>
                  )}
                </div>
              ) : (
                /* Chế độ CHỈNH SỬA (Edit Mode) */
                <div className="space-y-2.5">
                  <div className="flex items-center justify-between">
                    <span className="text-xs font-bold text-slate-700">Danh sách bài học kinh nghiệm:</span>
                    <button
                      type="button"
                      onClick={handleAddTroubleItem}
                      className="text-[10px] font-bold text-emerald-700 bg-emerald-100 hover:bg-emerald-200 px-2 py-0.5 rounded-lg flex items-center gap-0.5 transition"
                    >
                      <Plus className="w-3 h-3" /> Thêm dòng mẹo mới
                    </button>
                  </div>

                  {troubleList.map((item, idx) => (
                    <div key={idx} className="p-3 bg-slate-50 border border-slate-300 rounded-xl space-y-2 relative">
                      <div className="flex items-center justify-between">
                        <span className="text-[11px] font-bold text-slate-800">Mẹo #{idx + 1}</span>
                        <button
                          type="button"
                          onClick={() => handleRemoveTroubleItem(idx)}
                          className="p-1 text-rose-500 hover:bg-rose-100 rounded transition"
                          title="Xóa mẹo này"
                        >
                          <Trash2 className="w-3.5 h-3.5" />
                        </button>
                      </div>

                      <div>
                        <label className="text-[10px] font-bold text-slate-500 block mb-0.5">Hiện tượng / Sự cố:</label>
                        <input
                          type="text"
                          value={item.issue}
                          onChange={(e) => handleTroubleChange(idx, 'issue', e.target.value)}
                          placeholder="VD: Máy kêu to bất thường"
                          className="w-full bg-white border border-slate-300 rounded-lg px-2.5 py-1 text-xs font-semibold text-slate-900 focus:outline-none focus:border-amber-500"
                        />
                      </div>

                      <div>
                        <label className="text-[10px] font-bold text-slate-500 block mb-0.5">Cách khắc phục nhanh:</label>
                        <textarea
                          rows={2}
                          value={item.solution}
                          onChange={(e) => handleTroubleChange(idx, 'solution', e.target.value)}
                          placeholder="VD: Siết bu-lông chân máy & tra dầu ISO VG 68."
                          className="w-full bg-white border border-slate-300 rounded-lg px-2.5 py-1 text-xs font-medium text-slate-900 focus:outline-none focus:border-amber-500"
                        />
                      </div>
                    </div>
                  ))}

                  <div className="flex gap-2 pt-2">
                    <Button
                      type="button"
                      size="sm"
                      variant="default"
                      onClick={handleSaveTroubleshooting}
                      className="flex-1 bg-emerald-600 hover:bg-emerald-700 font-bold text-xs"
                    >
                      <Save className="w-3.5 h-3.5" /> Lưu Cẩm Nang Xử Lý Lỗi
                    </Button>
                    <Button
                      type="button"
                      size="sm"
                      variant="secondary"
                      onClick={() => {
                        setIsEditingTrouble(false);
                        setTroubleList(machine.quickTroubleshooting || []);
                      }}
                      className="text-xs font-bold"
                    >
                      Hủy
                    </Button>
                  </div>
                </div>
              )}
            </div>
          )}

          {activeTab === 'HISTORY' && (
            <div className="space-y-2.5">
              {machineWOs.map((wo) => (
                <div key={wo.id} className="p-3 rounded-xl bg-slate-50 border border-slate-200 flex items-start gap-2.5 text-xs">
                  <CheckCircle2 className="w-4 h-4 text-rose-600 shrink-0 mt-0.5" />
                  <div className="flex-1">
                    <div className="flex items-center justify-between">
                      <span className="font-mono text-[10px] font-bold text-rose-700">{wo.code}</span>
                      <Badge variant="outline" className="text-[9px]">{wo.status}</Badge>
                    </div>
                    <div className="font-bold text-slate-900">{wo.description}</div>
                    <div className="text-slate-500 text-[11px] mt-0.5">
                      Báo bởi: {wo.reporterName} • Kỹ sư: {wo.assigneeName || 'Đang xử lý'}
                    </div>
                  </div>
                </div>
              ))}

              {machinePMs.map((pm) => (
                <div key={pm.id} className="p-3 rounded-xl bg-slate-50 border border-slate-200 flex items-start gap-2.5 text-xs">
                  <CheckCircle2 className="w-4 h-4 text-emerald-600 shrink-0 mt-0.5" />
                  <div className="flex-1">
                    <div className="flex items-center justify-between">
                      <span className="font-mono text-[10px] font-bold text-emerald-700">{pm.code}</span>
                      <Badge variant="active" className="text-[9px]">{pm.status}</Badge>
                    </div>
                    <div className="font-bold text-slate-900">Bảo trì định kỳ mốc {pm.scheduledHours}{machine.trackingUnit === 'KM' ? 'km' : 'h'}</div>
                    <div className="text-slate-500 text-[11px] mt-0.5">
                      Kỹ sư: {pm.assigneeName || 'ME Engineer'} • Quản đốc đã ký nghiệm thu
                    </div>
                  </div>
                </div>
              ))}

              {machineWOs.length === 0 && machinePMs.length === 0 && (
                <>
                  <div className="p-3 rounded-xl bg-slate-50 border border-slate-200 flex items-start gap-3 text-xs">
                    <CheckCircle2 className="w-4 h-4 text-emerald-600 shrink-0 mt-0.5" />
                    <div>
                      <div className="font-bold text-slate-900">✓ 12/06 - Thay dầu bôi trơn 500h - Kỹ sư ME A</div>
                      <div className="text-slate-500 text-[11px]">Đã hoàn thành & Quản đốc ký nghiệm thu</div>
                    </div>
                  </div>
                  <div className="p-3 rounded-xl bg-slate-50 border border-slate-200 flex items-start gap-3 text-xs">
                    <CheckCircle2 className="w-4 h-4 text-rose-600 shrink-0 mt-0.5" />
                    <div>
                      <div className="font-bold text-slate-900">✓ 01/04 - Sửa SOS rò rỉ van áp - Kỹ sư ME B</div>
                      <div className="text-slate-500 text-[11px]">Đã thay cụm gioăng làm kín & bàn giao máy</div>
                    </div>
                  </div>
                </>
              )}
            </div>
          )}

        </div>

        {/* Footer Actions */}
        <div className="p-4 border-t border-slate-100 bg-white space-y-2">
          {userRole === 'OPERATOR' && (
            <Button
              variant="outline"
              size="lg"
              className="w-full h-11 text-xs font-extrabold border-slate-300 hover:bg-slate-50 text-slate-800"
              onClick={() => setShowHoursPopup(true)}
            >
              <PlusCircle className="w-4 h-4 text-emerald-600" /> [Cập nhật chỉ số vận hành]
            </Button>
          )}

          <Button
            variant="destructive"
            size="lg"
            className="w-full h-12 text-xs font-black animate-pulse"
            onClick={() => {
              onClose();
              onOpenSOS(machine);
            }}
          >
            <AlertTriangle className="w-4 h-4" /> [🚨 BÁO LỖI SOS KHẨN CẤP 🚨]
          </Button>
        </div>

      </div>
    </div>
  );
};
