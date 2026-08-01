'use client';

import React, { useState } from 'react';
import { X, Cpu, PlusCircle, Wrench, ShieldCheck, CheckCircle2 } from 'lucide-react';
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
  const [location, setLocation] = useState('Xưởng 1 - Dây chuyền C');
  const [trackingUnit, setTrackingUnit] = useState<'HOURS' | 'KM' | 'DAYS'>('HOURS');
  const [initialHours, setInitialHours] = useState('0');
  const [nextMaintenanceHours, setNextMaintenanceHours] = useState('500');
  const [manufacturer, setManufacturer] = useState('Haas Automation USA');
  const [year, setYear] = useState('2026');

  if (!isOpen) return null;

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();

    if (!code.trim() || !name.trim()) {
      alert('Vui lòng nhập đầy đủ Mã máy và Tên máy!');
      return;
    }

    const unitText = trackingUnit === 'KM' ? 'Km di chuyển' : trackingUnit === 'DAYS' ? 'Ngày vận hành' : 'Giờ máy chạy';

    const newMachineObj: Machine = {
      id: `mch-${Date.now()}`,
      code: code.trim().toUpperCase(),
      name: name.trim(),
      location: location.trim() || 'Xưởng Sản Xuất',
      category: category.trim() || 'Máy Móc Thiết Bị',
      status: 'ACTIVE',
      runningHours: parseFloat(initialHours) || 0,
      lastMaintenanceHours: 0,
      nextMaintenanceHours: parseFloat(nextMaintenanceHours) || 500,
      lastMaintenanceDate: new Date().toISOString().split('T')[0],
      trackingUnit,
      unitLabel: unitText,
      specifications: {
        power: '30 kW',
        voltage: '380V / 50Hz',
        manufacturer: manufacturer.trim() || 'Hãng Sản Xuất',
        year: parseInt(year) || 2026,
      },
      quickTroubleshooting: [
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

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-slate-900/60 backdrop-blur-sm p-4 animate-in fade-in duration-200">
      <div className="w-full max-w-md bg-white rounded-2xl overflow-hidden shadow-2xl border border-slate-200 animate-in zoom-in-95 duration-200">
        
        {/* Header */}
        <div className="p-4 bg-gradient-to-r from-emerald-600 to-teal-700 text-white flex items-center justify-between">
          <div className="flex items-center gap-2">
            <div className="p-1.5 rounded-lg bg-white/20">
              <Cpu className="w-5 h-5 text-white" />
            </div>
            <div>
              <h2 className="font-extrabold text-sm leading-tight">Thêm Hồ Sơ Máy Mới</h2>
              <p className="text-[10px] text-emerald-100 font-medium">Khởi tạo thiết bị & tự động sinh mã QR</p>
            </div>
          </div>
          <button
            onClick={onClose}
            className="p-1 rounded-full text-emerald-100 hover:text-white hover:bg-white/20 transition"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* Form Body */}
        <form onSubmit={handleSubmit} className="p-4 space-y-3 max-h-[80vh] overflow-y-auto">
          
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
              placeholder="VD: Xưởng 1 - Dây chuyền C"
              className="w-full bg-slate-50 border border-slate-300 rounded-xl px-3 py-2 text-xs font-medium text-slate-900 focus:outline-none focus:border-emerald-600"
              required
            />
          </div>

          {/* Unit selection */}
          <div className="p-2.5 rounded-xl bg-slate-50 border border-slate-200 space-y-2">
            <label className="text-[11px] font-bold text-slate-700 block">Đơn Vị Theo Dõi Bảo Trì:</label>
            <div className="grid grid-cols-3 gap-1.5 text-xs font-bold">
              <button
                type="button"
                onClick={() => setTrackingUnit('HOURS')}
                className={`py-1.5 rounded-lg border text-center transition ${
                  trackingUnit === 'HOURS'
                    ? 'bg-emerald-600 text-white border-emerald-600'
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
                    ? 'bg-emerald-600 text-white border-emerald-600'
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
                    ? 'bg-emerald-600 text-white border-emerald-600'
                    : 'bg-white text-slate-700 border-slate-300 hover:bg-slate-100'
                }`}
              >
                Ngày Vận Hành
              </button>
            </div>
          </div>

          <div className="grid grid-cols-2 gap-2.5">
            <div>
              <label className="text-[11px] font-bold text-slate-700 block mb-1">Chỉ Số Ban Đầu</label>
              <input
                type="number"
                value={initialHours}
                onChange={(e) => setInitialHours(e.target.value)}
                placeholder="0"
                className="w-full bg-slate-50 border border-slate-300 rounded-xl px-3 py-2 text-xs font-mono font-bold text-slate-900 focus:outline-none focus:border-emerald-600"
                required
              />
            </div>

            <div>
              <label className="text-[11px] font-bold text-slate-700 block mb-1">Mốc Bảo Trì Kế Tiếp</label>
              <input
                type="number"
                value={nextMaintenanceHours}
                onChange={(e) => setNextMaintenanceHours(e.target.value)}
                placeholder="500"
                className="w-full bg-slate-50 border border-slate-300 rounded-xl px-3 py-2 text-xs font-mono font-bold text-slate-900 focus:outline-none focus:border-emerald-600"
                required
              />
            </div>
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
