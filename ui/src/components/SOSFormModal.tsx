'use client';

import React, { useState } from 'react';
import { X, Camera, Send, ShieldAlert, Image as ImageIcon, WifiOff } from 'lucide-react';
import { Machine, SeverityLevel } from '../types';
import { Button } from '@/components/ui/button';

interface SOSFormModalProps {
  machine: Machine | null;
  isOpen: boolean;
  onClose: () => void;
  onSubmitSOS: (data: {
    machineId: string;
    machineName: string;
    machineCode: string;
    severity: SeverityLevel;
    description: string;
    imageUrl?: string;
    isOffline?: boolean;
  }) => void;
}

export const SOSFormModal: React.FC<SOSFormModalProps> = ({
  machine,
  isOpen,
  onClose,
  onSubmitSOS,
}) => {
  const [severity, setSeverity] = useState<SeverityLevel>('HIGH');
  const [description, setDescription] = useState('');
  const [photoUploaded, setPhotoUploaded] = useState(false);
  const [isOffline, setIsOffline] = useState(false);

  if (!isOpen || !machine) return null;

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!description.trim()) {
      alert('Vui lòng nhập mô tả sự cố hỏng hóc!');
      return;
    }

    const defaultImg = photoUploaded
      ? 'https://images.unsplash.com/photo-1581092160607-ee22621dd758?w=500&auto=format&fit=crop&q=80'
      : 'https://images.unsplash.com/photo-1581092335397-9583fe92d232?w=500&auto=format&fit=crop&q=80';

    onSubmitSOS({
      machineId: machine.id,
      machineName: machine.name,
      machineCode: machine.code,
      severity,
      description,
      imageUrl: defaultImg,
      isOffline,
    });

    setDescription('');
    setPhotoUploaded(false);
    onClose();
  };

  return (
    <div className="fixed inset-0 z-50 flex items-end sm:items-center justify-center bg-slate-900/60 backdrop-blur-sm p-0 sm:p-4">
      <div className="w-full max-w-md bg-white border border-slate-200 rounded-t-3xl sm:rounded-3xl overflow-hidden shadow-2xl animate-in slide-in-from-bottom duration-300">
        
        {/* Header */}
        <div className="p-4 bg-rose-50 border-b border-rose-100 flex items-center justify-between">
          <div className="flex items-center gap-2.5 text-rose-700">
            <ShieldAlert className="w-6 h-6 animate-pulse" />
            <div>
              <h2 className="font-extrabold text-slate-900 text-sm">Tạo Phiếu SOS Khẩn Cấp</h2>
              <p className="text-xs text-rose-600 font-semibold">Báo hỏng máy dừng chuyền đột xuất</p>
            </div>
          </div>
          <button
            onClick={onClose}
            className="p-1.5 rounded-full text-slate-400 hover:text-slate-700 hover:bg-rose-100/60 transition"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* Offline Mode Toggle Bar (NFR-06) */}
        <div className="px-4 pt-3">
          <div className="flex items-center justify-between p-2.5 rounded-xl bg-slate-100 border border-slate-200">
            <div className="flex items-center gap-2 text-xs font-bold text-slate-700">
              <WifiOff className={`w-4 h-4 ${isOffline ? 'text-amber-600' : 'text-slate-400'}`} />
              <span>Mô phỏng mất mạng (Offline Queue):</span>
            </div>
            <button
              type="button"
              onClick={() => setIsOffline(!isOffline)}
              className={`px-2.5 py-1 rounded-lg text-xs font-black transition ${
                isOffline ? 'bg-amber-500 text-white' : 'bg-slate-200 text-slate-600'
              }`}
            >
              {isOffline ? 'OFFLINE' : 'ONLINE'}
            </button>
          </div>

          {/* Offline Warning Banner (NFR-06 section 3) */}
          {isOffline && (
            <div className="mt-2 p-2.5 rounded-xl bg-rose-50 border border-rose-200 text-[11px] text-rose-800 font-medium leading-snug animate-in fade-in duration-200">
              ⚠️ <strong>Không có mạng:</strong> Phiếu SOS & Ảnh sẽ lưu vào Local Queue (SQLite). Notification sẽ chỉ gửi tới kỹ sư sau khi có kết nối trở lại. Hãy thông báo trực tiếp nếu sự cố nghiêm trọng!
            </div>
          )}
        </div>

        {/* Machine Badge */}
        <div className="px-4 pt-3">
          <div className="p-3 rounded-2xl bg-slate-50 border border-slate-200 flex items-center justify-between">
            <div>
              <span className="text-[11px] text-slate-500 font-medium block">Thiết Bị Sự Cố:</span>
              <span className="text-sm font-extrabold text-slate-900">{machine.name}</span>
            </div>
            <span className="px-2.5 py-1 rounded bg-rose-100 text-rose-800 font-mono text-xs font-black border border-rose-200">
              {machine.code}
            </span>
          </div>
        </div>

        {/* Form Body */}
        <form onSubmit={handleSubmit} className="p-4 space-y-3.5">
          
          {/* Severity Selector */}
          <div>
            <label className="block text-xs font-extrabold text-slate-800 mb-1.5">Mức Độ Nghiêm Trọng:</label>
            <div className="grid grid-cols-4 gap-1.5">
              {(['LOW', 'MEDIUM', 'HIGH', 'CRITICAL'] as SeverityLevel[]).map((level) => {
                const isSelected = severity === level;
                let activeColor = 'bg-rose-600 text-white border-rose-600';
                if (level === 'LOW') activeColor = 'bg-emerald-600 text-white border-emerald-600';
                if (level === 'MEDIUM') activeColor = 'bg-amber-600 text-white border-amber-600';
                if (level === 'HIGH') activeColor = 'bg-orange-600 text-white border-orange-600';

                return (
                  <button
                    type="button"
                    key={level}
                    onClick={() => setSeverity(level)}
                    className={`py-2 px-1 rounded-xl text-[11px] font-extrabold border transition ${
                      isSelected
                        ? activeColor
                        : 'bg-slate-50 border-slate-200 text-slate-600 hover:bg-slate-100'
                    }`}
                  >
                    {level}
                  </button>
                );
              })}
            </div>
          </div>

          {/* Issue Description */}
          <div>
            <label className="block text-xs font-extrabold text-slate-800 mb-1">Mô Tả Chi Tiết Sự Cố:</label>
            <textarea
              rows={3}
              required
              placeholder="Ví dụ: Rò rỉ dầu thủy lực xi lanh ép, máy rít lớn kêu lạch cạch..."
              value={description}
              onChange={(e) => setDescription(e.target.value)}
              className="w-full bg-slate-50 border border-slate-200 rounded-xl p-3 text-xs text-slate-900 placeholder-slate-400 focus:outline-none focus:border-rose-500 focus:bg-white transition"
            />
          </div>

          {/* Photo Attachment Simulator */}
          <div>
            <label className="block text-xs font-extrabold text-slate-800 mb-1">Hình Ảnh Minh Chứng Lỗi:</label>
            <button
              type="button"
              onClick={() => setPhotoUploaded(!photoUploaded)}
              className={`w-full p-3.5 rounded-xl border-2 border-dashed flex flex-col items-center justify-center transition ${
                photoUploaded
                  ? 'border-emerald-500 bg-emerald-50 text-emerald-800'
                  : 'border-slate-300 bg-slate-50 text-slate-500 hover:border-slate-400'
              }`}
            >
              {photoUploaded ? (
                <>
                  <ImageIcon className="w-5 h-5 mb-1 text-emerald-600" />
                  <span className="text-xs font-extrabold text-emerald-800">Đã đính kèm 1 ảnh minh chứng</span>
                  <span className="text-[10px] text-slate-500">Chạm để chụp lại</span>
                </>
              ) : (
                <>
                  <Camera className="w-5 h-5 mb-1 text-rose-600" />
                  <span className="text-xs font-bold text-slate-700">Chụp / Đính kèm ảnh hiện trạng sự cố</span>
                  <span className="text-[10px] text-slate-400">(Tự động nén &lt; 5MB per NFR-04)</span>
                </>
              )}
            </button>
          </div>

          {/* Submit Action */}
          <div className="pt-1">
            <Button
              type="submit"
              variant="destructive"
              className="w-full h-11 text-xs font-black"
            >
              <Send className="w-4 h-4" /> {isOffline ? 'Lưu Vào Queue Offline' : 'Gửi Yêu Cầu SOS Tức Thời'}
            </Button>
          </div>

        </form>

      </div>
    </div>
  );
};
