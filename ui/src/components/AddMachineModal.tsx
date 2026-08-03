'use client';

import React, { useState } from 'react';
import { X, Cpu, PlusCircle, Plus, Trash2, Info, Wrench, HelpCircle } from 'lucide-react';
import { Machine } from '../types';

interface AddMachineModalProps {
  isOpen: boolean;
  onClose: () => void;
  onAddMachine: (newMachine: Machine) => void;
}

export const AddMachineModal: React.FC<AddMachineModalProps> = ({
  isOpen,
  onClose,
  onAddMachine,
}) => {
  const [code, setCode] = useState('MC-103');
  const [name, setName] = useState('Máy Phay CNC Haas 3 Trục');
  const [category, setCategory] = useState('Gia Công CNC');
  const [location, setLocation] = useState('Phân Xưởng 1 - Dây chuyền C');
  const [trackingUnit, setTrackingUnit] = useState<'HOURS' | 'KM' | 'DAYS'>('HOURS');
  const [initialHours, setInitialHours] = useState('0');
  
  // Mốc bảo trì ban đầu (chạy rà/roda) & chu kỳ lặp lại
  const [initialThresholds, setInitialThresholds] = useState<number[]>([500, 1000]);
  const [recurringInterval, setRecurringInterval] = useState<string>('500');

  // Cẩm nang xử lý lỗi nhanh (Quick Troubleshooting)
  const [quickTroubleshooting, setQuickTroubleshooting] = useState<Array<{ issue: string; solution: string }>>([
    {
      issue: 'Máy rung mạnh bất thường khi vận hành',
      solution: 'Kiểm tra & siết chặt bu-lông chân máy, tra thêm dầu bôi trơn ISO VG 68.',
    },
  ]);

  const [manufacturer, setManufacturer] = useState('Haas Automation USA');
  const [year, setYear] = useState('2026');

  if (!isOpen) return null;

  const handleAddThreshold = () => {
    const lastVal = initialThresholds.length > 0 ? initialThresholds[initialThresholds.length - 1] : 0;
    const interval = parseFloat(recurringInterval) || 500;
    setInitialThresholds([...initialThresholds, lastVal + interval]);
  };

  const handleRemoveThreshold = (index: number) => {
    if (initialThresholds.length <= 1) {
      alert('Phải giữ ít nhất 1 mốc bảo trì ban đầu!');
      return;
    }
    setInitialThresholds(initialThresholds.filter((_, i) => i !== index));
  };

  const handleThresholdChange = (index: number, val: string) => {
    const num = parseFloat(val) || 0;
    const updated = [...initialThresholds];
    updated[index] = num;
    setInitialThresholds(updated);
  };

  // Thêm/Xóa Cẩm nang xử lý lỗi nhanh
  const handleAddTrouble = () => {
    setQuickTroubleshooting([
      ...quickTroubleshooting,
      { issue: '', solution: '' },
    ]);
  };

  const handleRemoveTrouble = (index: number) => {
    setQuickTroubleshooting(quickTroubleshooting.filter((_, i) => i !== index));
  };

  const handleTroubleChange = (index: number, field: 'issue' | 'solution', val: string) => {
    const updated = [...quickTroubleshooting];
    updated[index][field] = val;
    setQuickTroubleshooting(updated);
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();

    if (!code.trim() || !name.trim()) {
      alert('Vui lòng nhập đầy đủ Mã máy và Tên máy!');
      return;
    }

    const unitText = trackingUnit === 'KM' ? 'Km' : trackingUnit === 'DAYS' ? 'Ngày' : 'Giờ';
    const firstMilestone = initialThresholds.length > 0 ? initialThresholds[0] : (parseFloat(recurringInterval) || 500);

    // Lọc bỏ các mẹo trống
    const validTroubleshooting = quickTroubleshooting.filter(
      (item) => item.issue.trim() !== '' || item.solution.trim() !== ''
    );

    const newMachineObj: Machine = {
      id: `mch-${Date.now()}`,
      code: code.trim().toUpperCase(),
      name: name.trim(),
      location: location.trim() || 'Phân Xưởng Sản Xuất',
      category: category.trim() || 'Máy Móc Thiết Bị',
      status: 'ACTIVE',
      runningHours: parseFloat(initialHours) || 0,
      lastMaintenanceHours: 0,
      nextMaintenanceHours: firstMilestone,
      lastMaintenanceDate: new Date().toISOString().split('T')[0],
      trackingUnit,
      unitLabel: unitText,
      pmConfig: {
        initialThresholds,
        recurringInterval: parseFloat(recurringInterval) || 500,
      },
      specifications: {
        power: '30 kW',
        voltage: '380V / 50Hz',
        manufacturer: manufacturer.trim() || 'Hãng Sản Xuất',
        year: parseInt(year) || 2026,
      },
      quickTroubleshooting: validTroubleshooting.length > 0 ? validTroubleshooting : [
        {
          issue: 'Kiểm tra dầu bôi trơn hệ thống trước khi vận hành',
          solution: 'Châm thêm dầu ISO VG 68 nếu bình báo dưới mốc MIN.',
        },
      ],
    };

    onAddMachine(newMachineObj);
    alert(`✅ Đã thêm thiết bị mới [${newMachineObj.code}] ${newMachineObj.name} thành công! Mã QR đã được tự động khởi tạo.`);
    onClose();
  };

  const getUnitSymbol = () => {
    if (trackingUnit === 'KM') return 'km';
    if (trackingUnit === 'DAYS') return 'ngày';
    return 'h';
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-slate-900/60 backdrop-blur-sm p-4 animate-in fade-in duration-200">
      <div className="w-full max-w-lg bg-white rounded-2xl overflow-hidden shadow-2xl border border-slate-200 animate-in zoom-in-95 duration-200">
        
        {/* Header */}
        <div className="p-4 bg-gradient-to-r from-emerald-600 to-teal-700 text-white flex items-center justify-between">
          <div className="flex items-center gap-2">
            <div className="p-1.5 rounded-lg bg-white/20">
              <Cpu className="w-5 h-5 text-white" />
            </div>
            <div>
              <h2 className="font-extrabold text-sm leading-tight">Thêm Hồ Sơ Máy Mới</h2>
              <p className="text-[10px] text-emerald-100 font-medium">Cấu hình mốc bảo trì & Cẩm nang xử lý lỗi nhanh</p>
            </div>
          </div>
          <button
            onClick={onClose}
            type="button"
            className="p-1 rounded-full text-emerald-100 hover:text-white hover:bg-white/20 transition"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* Form Body */}
        <form onSubmit={handleSubmit} className="p-4 space-y-3.5 max-h-[82vh] overflow-y-auto">
          
          <div className="grid grid-cols-2 gap-2.5">
            <div>
              <label className="text-[11px] font-bold text-slate-700 block mb-1">Mã Thiết Bị (Mã QR)</label>
              <input
                type="text"
                value={code}
                onChange={(e) => setCode(e.target.value)}
                placeholder="VD: MC-103"
                className="w-full bg-slate-50 border border-slate-300 rounded-xl px-3 py-2 text-xs font-mono font-bold text-slate-900 focus:outline-none focus:border-emerald-600"
                required
              />
            </div>

            <div>
              <label className="text-[11px] font-bold text-slate-700 block mb-1">Phân Loại Thiết Bị</label>
              <input
                type="text"
                value={category}
                onChange={(e) => setCategory(e.target.value)}
                placeholder="VD: Gia Công CNC"
                className="w-full bg-slate-50 border border-slate-300 rounded-xl px-3 py-2 text-xs font-bold text-slate-900 focus:outline-none focus:border-emerald-600"
                required
              />
            </div>
          </div>

          <div>
            <label className="text-[11px] font-bold text-slate-700 block mb-1">Tên Máy / Thiết Bị</label>
            <input
              type="text"
              value={name}
              onChange={(e) => setName(e.target.value)}
              placeholder="VD: Máy Phay CNC Haas 3 Trục"
              className="w-full bg-slate-50 border border-slate-300 rounded-xl px-3 py-2 text-xs font-bold text-slate-900 focus:outline-none focus:border-emerald-600"
              required
            />
          </div>

          <div>
            <label className="text-[11px] font-bold text-slate-700 block mb-1">Vị Trí Lắp Đặt / Phân Xưởng</label>
            <input
              type="text"
              value={location}
              onChange={(e) => setLocation(e.target.value)}
              placeholder="VD: Phân Xưởng 1 - Dây chuyền C"
              className="w-full bg-slate-50 border border-slate-300 rounded-xl px-3 py-2 text-xs font-medium text-slate-900 focus:outline-none focus:border-emerald-600"
              required
            />
          </div>

          {/* Unit selection */}
          <div className="p-3 rounded-xl bg-slate-50 border border-slate-200 space-y-2">
            <label className="text-[11px] font-bold text-slate-700 block">Đơn Vị Theo Dõi Bảo Trì:</label>
            <div className="grid grid-cols-3 gap-1.5 text-xs font-bold">
              <button
                type="button"
                onClick={() => setTrackingUnit('HOURS')}
                className={`py-1.5 rounded-lg border text-center transition ${
                  trackingUnit === 'HOURS'
                    ? 'bg-emerald-600 text-white border-emerald-600 shadow-sm'
                    : 'bg-white text-slate-700 border-slate-300 hover:bg-slate-100'
                }`}
              >
                Giờ Máy (h)
              </button>
              <button
                type="button"
                onClick={() => setTrackingUnit('KM')}
                className={`py-1.5 rounded-lg border text-center transition ${
                  trackingUnit === 'KM'
                    ? 'bg-emerald-600 text-white border-emerald-600 shadow-sm'
                    : 'bg-white text-slate-700 border-slate-300 hover:bg-slate-100'
                }`}
              >
                Km Di Chuyển
              </button>
              <button
                type="button"
                onClick={() => setTrackingUnit('DAYS')}
                className={`py-1.5 rounded-lg border text-center transition ${
                  trackingUnit === 'DAYS'
                    ? 'bg-emerald-600 text-white border-emerald-600 shadow-sm'
                    : 'bg-white text-slate-700 border-slate-300 hover:bg-slate-100'
                }`}
              >
                Ngày Vận Hành
              </button>
            </div>
          </div>

          {/* Initial value & Dynamic Thresholds section */}
          <div className="p-3 rounded-xl bg-emerald-50/60 border border-emerald-200 space-y-3">
            <div className="flex items-center justify-between">
              <label className="text-[11px] font-extrabold text-emerald-900 flex items-center gap-1">
                <Info className="w-3.5 h-3.5 text-emerald-600" /> Cấu Hình Mốc Bảo Trì Lặp Lại:
              </label>
              <span className="text-[10px] text-emerald-700 font-semibold uppercase">Đơn vị: {getUnitSymbol()}</span>
            </div>

            <div className="grid grid-cols-2 gap-2.5">
              <div>
                <label className="text-[10px] font-bold text-slate-700 block mb-1">Chỉ Số Ban Đầu Hiện Tại</label>
                <input
                  type="number"
                  value={initialHours}
                  onChange={(e) => setInitialHours(e.target.value)}
                  placeholder="0"
                  className="w-full bg-white border border-slate-300 rounded-xl px-3 py-1.5 text-xs font-mono font-bold text-slate-900 focus:outline-none focus:border-emerald-600"
                  required
                />
              </div>

              <div>
                <label className="text-[10px] font-bold text-slate-700 block mb-1">Chu Kỳ Lặp Lại Sau Đó</label>
                <div className="relative">
                  <input
                    type="number"
                    value={recurringInterval}
                    onChange={(e) => setRecurringInterval(e.target.value)}
                    placeholder="500"
                    className="w-full bg-white border border-slate-300 rounded-xl pl-3 pr-10 py-1.5 text-xs font-mono font-bold text-slate-900 focus:outline-none focus:border-emerald-600"
                    required
                  />
                  <span className="absolute right-3 top-1.5 text-xs text-slate-500 font-bold">{getUnitSymbol()}</span>
                </div>
              </div>
            </div>

            {/* Initial thresholds list */}
            <div>
              <div className="flex items-center justify-between mb-1.5">
                <span className="text-[11px] font-bold text-slate-800">Các Mốc Chạy Rà Ban Đầu:</span>
                <button
                  type="button"
                  onClick={handleAddThreshold}
                  className="text-[10px] font-bold text-emerald-700 hover:text-emerald-800 flex items-center gap-0.5 bg-emerald-100 hover:bg-emerald-200 px-2 py-0.5 rounded-lg transition"
                >
                  <Plus className="w-3 h-3" /> Thêm mốc
                </button>
              </div>

              <div className="space-y-1.5">
                {initialThresholds.map((thresh, idx) => (
                  <div key={idx} className="flex items-center gap-2">
                    <span className="text-[10px] font-bold text-slate-500 w-12">Lần {idx + 1}:</span>
                    <div className="relative flex-1">
                      <input
                        type="number"
                        value={thresh}
                        onChange={(e) => handleThresholdChange(idx, e.target.value)}
                        className="w-full bg-white border border-slate-300 rounded-lg px-2.5 py-1 text-xs font-mono font-bold text-slate-900 focus:outline-none focus:border-emerald-600"
                        required
                      />
                      <span className="absolute right-2 top-1 text-[11px] text-slate-400 font-medium">{getUnitSymbol()}</span>
                    </div>
                    {initialThresholds.length > 1 && (
                      <button
                        type="button"
                        onClick={() => handleRemoveThreshold(idx)}
                        className="p-1 text-rose-500 hover:bg-rose-50 rounded-lg transition"
                        title="Xóa mốc"
                      >
                        <Trash2 className="w-3.5 h-3.5" />
                      </button>
                    )}
                  </div>
                ))}
              </div>
            </div>

            {/* Helpful preview text */}
            <div className="text-[10px] text-emerald-800 bg-emerald-100/70 p-2 rounded-lg leading-relaxed">
              💡 <strong>Lịch nhắc tự động:</strong> Máy sẽ được báo bảo trì ở các mốc{' '}
              <strong className="underline">{initialThresholds.join(`${getUnitSymbol()}, `)}{getUnitSymbol()}</strong> và sau đó cứ mỗi{' '}
              <strong className="underline">{recurringInterval || 500} {getUnitSymbol()}</strong> lại nhắc 1 lần ({initialThresholds.length > 0 ? (initialThresholds[initialThresholds.length - 1] + (parseFloat(recurringInterval) || 500)) : 500}{getUnitSymbol()}, {initialThresholds.length > 0 ? (initialThresholds[initialThresholds.length - 1] + (parseFloat(recurringInterval) || 500) * 2) : 1000}{getUnitSymbol()}...).
            </div>
          </div>

          {/* Quick Troubleshooting Guide Section */}
          <div className="p-3 rounded-xl bg-amber-50/70 border border-amber-200 space-y-2.5">
            <div className="flex items-center justify-between">
              <label className="text-[11px] font-extrabold text-amber-900 flex items-center gap-1">
                <Wrench className="w-3.5 h-3.5 text-amber-600" /> Cẩm Nang Xử Lý Lỗi Nhanh (Mẹo Cho Công Nhân):
              </label>
              <button
                type="button"
                onClick={handleAddTrouble}
                className="text-[10px] font-bold text-amber-800 hover:text-amber-900 flex items-center gap-0.5 bg-amber-200/70 hover:bg-amber-200 px-2 py-0.5 rounded-lg transition"
              >
                <Plus className="w-3 h-3" /> Thêm mẹo lỗi
              </button>
            </div>

            {quickTroubleshooting.length === 0 ? (
              <p className="text-[10px] text-amber-700 italic">Chưa có mẹo xử lý lỗi nào được thêm.</p>
            ) : (
              <div className="space-y-2">
                {quickTroubleshooting.map((item, idx) => (
                  <div key={idx} className="p-2 bg-white rounded-lg border border-amber-200 relative space-y-1.5">
                    <div className="flex items-center justify-between">
                      <span className="text-[10px] font-bold text-amber-800">Mẹo #{idx + 1}</span>
                      <button
                        type="button"
                        onClick={() => handleRemoveTrouble(idx)}
                        className="text-rose-500 hover:bg-rose-50 p-0.5 rounded transition"
                        title="Xóa mẹo"
                      >
                        <Trash2 className="w-3.5 h-3.5" />
                      </button>
                    </div>

                    <div>
                      <input
                        type="text"
                        value={item.issue}
                        onChange={(e) => handleTroubleChange(idx, 'issue', e.target.value)}
                        placeholder="Hiện tượng / Sự cố (VD: Máy rung mạnh, Áp suất giảm...)"
                        className="w-full bg-slate-50 border border-slate-300 rounded-lg px-2.5 py-1 text-xs font-semibold text-slate-900 focus:outline-none focus:border-amber-500"
                      />
                    </div>

                    <div>
                      <input
                        type="text"
                        value={item.solution}
                        onChange={(e) => handleTroubleChange(idx, 'solution', e.target.value)}
                        placeholder="Cách khắc phục nhanh (VD: Siết bu-lông chân máy, châm dầu...)"
                        className="w-full bg-slate-50 border border-slate-300 rounded-lg px-2.5 py-1 text-xs font-medium text-slate-800 focus:outline-none focus:border-amber-500"
                      />
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>

          <div className="grid grid-cols-2 gap-2.5">
            <div>
              <label className="text-[11px] font-bold text-slate-700 block mb-1">Hãng Sản Xuất</label>
              <input
                type="text"
                value={manufacturer}
                onChange={(e) => setManufacturer(e.target.value)}
                placeholder="Haas USA"
                className="w-full bg-slate-50 border border-slate-300 rounded-xl px-3 py-2 text-xs text-slate-900 focus:outline-none focus:border-emerald-600"
              />
            </div>

            <div>
              <label className="text-[11px] font-bold text-slate-700 block mb-1">Năm Sản Xuất</label>
              <input
                type="number"
                value={year}
                onChange={(e) => setYear(e.target.value)}
                placeholder="2026"
                className="w-full bg-slate-50 border border-slate-300 rounded-xl px-3 py-2 text-xs text-slate-900 focus:outline-none focus:border-emerald-600"
              />
            </div>
          </div>

          {/* Submit */}
          <div className="pt-2">
            <button
              type="submit"
              className="w-full py-2.5 rounded-xl bg-emerald-600 hover:bg-emerald-700 text-white text-xs font-extrabold flex items-center justify-center gap-1.5 shadow-md transition"
            >
              <PlusCircle className="w-4 h-4" /> Tạo Hồ Sơ & Sinh Mã QR Thiết Bị
            </button>
          </div>

        </form>

      </div>
    </div>
  );
};
