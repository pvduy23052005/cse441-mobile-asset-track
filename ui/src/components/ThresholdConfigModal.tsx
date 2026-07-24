'use client';

import React, { useState } from 'react';
import { X, Sliders, DollarSign, Clock, Plus, Trash2, CheckCircle2, ShieldCheck } from 'lucide-react';
import { SystemThresholdConfig } from '../types';
import { Button } from '@/components/ui/button';
import { Card, CardHeader, CardTitle, CardContent } from '@/components/ui/card';

interface ThresholdConfigModalProps {
  isOpen: boolean;
  onClose: () => void;
  config: SystemThresholdConfig;
  onSaveConfig: (newConfig: SystemThresholdConfig) => void;
}

export const ThresholdConfigModal: React.FC<ThresholdConfigModalProps> = ({
  isOpen,
  onClose,
  config,
  onSaveConfig,
}) => {
  const [costThreshold, setCostThreshold] = useState(config.costApprovalThreshold.toString());
  const [intervals, setIntervals] = useState<number[]>([...config.pmIntervals]);
  const [newInterval, setNewInterval] = useState('');

  if (!isOpen) return null;

  const handleAddInterval = () => {
    const val = parseInt(newInterval);
    if (!isNaN(val) && val > 0 && !intervals.includes(val)) {
      setIntervals((prev) => [...prev, val].sort((a, b) => a - b));
      setNewInterval('');
    }
  };

  const handleRemoveInterval = (val: number) => {
    setIntervals((prev) => prev.filter((i) => i !== val));
  };

  const handleSave = (e: React.FormEvent) => {
    e.preventDefault();
    const costVal = parseInt(costThreshold);
    if (isNaN(costVal) || costVal < 0) {
      alert('Vui lòng nhập ngưỡng chi phí hợp lệ!');
      return;
    }
    if (intervals.length === 0) {
      alert('Vui lòng tạo ít nhất 1 mốc giờ bảo trì PM!');
      return;
    }

    onSaveConfig({
      ...config,
      costApprovalThreshold: costVal,
      pmIntervals: intervals,
    });
    onClose();
  };

  return (
    <div className="fixed inset-0 z-50 flex items-end sm:items-center justify-center bg-slate-900/60 backdrop-blur-sm p-0 sm:p-4 animate-in fade-in duration-200">
      <div className="w-full max-w-md bg-white border border-slate-200 rounded-t-2xl sm:rounded-2xl overflow-hidden shadow-2xl animate-in slide-in-from-bottom duration-300">
        
        {/* Header */}
        <div className="p-4 bg-slate-50 border-b border-slate-200 flex items-center justify-between">
          <div className="flex items-center gap-2.5">
            <div className="p-2 rounded-lg bg-amber-50 text-amber-700 border border-amber-200">
              <Sliders className="w-5 h-5" />
            </div>
            <div>
              <h2 className="font-extrabold text-slate-900 text-sm">Cấu Hình Ngưỡng Hệ Thống</h2>
              <p className="text-[11px] text-slate-500 font-medium">{config.workshopName}</p>
            </div>
          </div>
          <button
            onClick={onClose}
            className="p-1.5 rounded-full text-slate-400 hover:text-slate-700 hover:bg-slate-200/60 transition"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* Form Body */}
        <form onSubmit={handleSave} className="p-4 space-y-4 max-h-[80vh] overflow-y-auto">
          
          {/* Cost Approval Threshold Settings */}
          <Card>
            <CardHeader className="p-3.5 pb-2">
              <CardTitle className="text-xs flex items-center gap-1.5 text-slate-800">
                <DollarSign className="w-4 h-4 text-emerald-600" />
                Ngưỡng Chi Phí Duyệt Linh Kiện (VND)
              </CardTitle>
            </CardHeader>
            <CardContent className="p-3.5 pt-0 space-y-2">
              <p className="text-[11px] text-slate-500 leading-snug">
                Đề xuất thay phụ tùng có giá trị vượt ngưỡng này sẽ bắt buộc gửi lên Quản đốc phê duyệt. Dưới ngưỡng ME tự động ghi nhận.
              </p>
              <div className="relative">
                <input
                  type="number"
                  step="100000"
                  value={costThreshold}
                  onChange={(e) => setCostThreshold(e.target.value)}
                  className="w-full bg-slate-50 border border-slate-300 rounded-xl px-3 py-2 text-xs font-bold font-mono text-emerald-700 focus:outline-none focus:border-emerald-500"
                  required
                />
                <span className="absolute right-3 top-2 text-xs font-bold text-slate-400">VND</span>
              </div>
              <div className="text-[11px] text-emerald-700 font-bold bg-emerald-50 p-2 rounded-lg border border-emerald-200">
                Hiển thị: {parseInt(costThreshold || '0').toLocaleString('vi-VN')} VNĐ
              </div>
            </CardContent>
          </Card>

          {/* PM Intervals Settings */}
          <Card>
            <CardHeader className="p-3.5 pb-2">
              <CardTitle className="text-xs flex items-center gap-1.5 text-slate-800">
                <Clock className="w-4 h-4 text-amber-600" />
                Các Mốc Số Giờ Bảo Trì Định Kỳ (PM Intervals)
              </CardTitle>
            </CardHeader>
            <CardContent className="p-3.5 pt-0 space-y-2.5">
              <p className="text-[11px] text-slate-500 leading-snug">
                Khi chỉ số giờ máy chạy đạt các mốc này, hệ thống sẽ tự động tạo phiếu PM Checklist gửi cho ME Engineer.
              </p>

              <div className="flex gap-2">
                <input
                  type="number"
                  placeholder="Nhập mốc giờ (e.g. 500)"
                  value={newInterval}
                  onChange={(e) => setNewInterval(e.target.value)}
                  className="flex-1 bg-slate-50 border border-slate-300 rounded-xl px-3 py-1.5 text-xs font-bold font-mono text-slate-900 focus:outline-none focus:border-amber-500"
                />
                <Button type="button" variant="amber" size="sm" onClick={handleAddInterval}>
                  <Plus className="w-4 h-4" /> Thêm Mốc
                </Button>
              </div>

              <div className="flex flex-wrap gap-2 pt-1">
                {intervals.map((hrs) => (
                  <span
                    key={hrs}
                    className="inline-flex items-center gap-1.5 px-3 py-1 rounded-xl bg-amber-50 border border-amber-200 text-amber-800 text-xs font-extrabold font-mono"
                  >
                    {hrs} Giờ
                    <button
                      type="button"
                      onClick={() => handleRemoveInterval(hrs)}
                      className="text-rose-600 hover:text-rose-800 ml-0.5"
                    >
                      <Trash2 className="w-3 h-3" />
                    </button>
                  </span>
                ))}
              </div>
            </CardContent>
          </Card>

          {/* Security Note */}
          <div className="p-2.5 rounded-xl bg-slate-100 border border-slate-200 text-[11px] text-slate-500 flex items-center gap-2">
            <ShieldCheck className="w-4 h-4 text-slate-400 shrink-0" />
            <span>Chỉ Quản đốc phụ trách phân xưởng này mới có quyền lưu thay đổi cấu hình (Bảo mật RLS).</span>
          </div>

          {/* Action */}
          <div className="pt-2">
            <Button type="submit" variant="default" className="w-full h-10 text-xs font-extrabold">
              <CheckCircle2 className="w-4 h-4" /> Lưu Cấu Hình Ngưỡng Hệ Thống
            </Button>
          </div>

        </form>

      </div>
    </div>
  );
};
