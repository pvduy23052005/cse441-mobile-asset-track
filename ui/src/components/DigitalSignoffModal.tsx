'use client';

import React, { useRef, useState, useEffect } from 'react';
import { X, RotateCcw, CheckCircle2, ShieldCheck, PenTool, XCircle, AlertTriangle, Wrench, Clock, PackageCheck } from 'lucide-react';
import { Button } from '@/components/ui/button';

export interface WorkSummaryInfo {
  machineName: string;
  machineCode: string;
  engineerName?: string;
  downtimeDuration?: string;
  spareParts?: { name: string; quantity: number }[];
}

interface DigitalSignoffModalProps {
  isOpen: boolean;
  onClose: () => void;
  onConfirmSign: (signatureDataUrl: string) => void;
  onReject?: (reason: string) => void;
  title: string;
  subtitle: string;
  itemCode: string;
  workSummary?: WorkSummaryInfo;
}

export const DigitalSignoffModal: React.FC<DigitalSignoffModalProps> = ({
  isOpen,
  onClose,
  onConfirmSign,
  onReject,
  title,
  subtitle,
  itemCode,
  workSummary,
}) => {
  const canvasRef = useRef<HTMLCanvasElement | null>(null);
  const [isDrawing, setIsDrawing] = useState(false);
  const [hasSigned, setHasSigned] = useState(false);
  const [showRejectForm, setShowRejectForm] = useState(false);
  const [rejectionReason, setRejectionReason] = useState('');

  useEffect(() => {
    if (isOpen) {
      setHasSigned(false);
      setShowRejectForm(false);
      setRejectionReason('');
      setTimeout(() => {
        const canvas = canvasRef.current;
        if (canvas) {
          const ctx = canvas.getContext('2d');
          if (ctx) {
            ctx.clearRect(0, 0, canvas.width, canvas.height);
            ctx.strokeStyle = '#0284c7'; // Deep blue ink signature stroke
            ctx.lineWidth = 3;
            ctx.lineCap = 'round';
            ctx.lineJoin = 'round';
          }
        }
      }, 100);
    }
  }, [isOpen]);

  if (!isOpen) return null;

  const startDrawing = (e: React.MouseEvent<HTMLCanvasElement> | React.TouchEvent<HTMLCanvasElement>) => {
    const canvas = canvasRef.current;
    if (!canvas) return;
    const ctx = canvas.getContext('2d');
    if (!ctx) return;

    setIsDrawing(true);
    setHasSigned(true);

    const rect = canvas.getBoundingClientRect();
    const clientX = 'touches' in e ? e.touches[0].clientX : e.clientX;
    const clientY = 'touches' in e ? e.touches[0].clientY : e.clientY;

    ctx.beginPath();
    ctx.moveTo(clientX - rect.left, clientY - rect.top);
  };

  const draw = (e: React.MouseEvent<HTMLCanvasElement> | React.TouchEvent<HTMLCanvasElement>) => {
    if (!isDrawing) return;
    const canvas = canvasRef.current;
    if (!canvas) return;
    const ctx = canvas.getContext('2d');
    if (!ctx) return;

    const rect = canvas.getBoundingClientRect();
    const clientX = 'touches' in e ? e.touches[0].clientX : e.clientX;
    const clientY = 'touches' in e ? e.touches[0].clientY : e.clientY;

    ctx.lineTo(clientX - rect.left, clientY - rect.top);
    ctx.stroke();
  };

  const stopDrawing = () => {
    setIsDrawing(false);
  };

  const clearCanvas = () => {
    const canvas = canvasRef.current;
    if (!canvas) return;
    const ctx = canvas.getContext('2d');
    if (!ctx) return;
    ctx.clearRect(0, 0, canvas.width, canvas.height);
    setHasSigned(false);
  };

  const handleSave = () => {
    const canvas = canvasRef.current;
    if (!canvas || !hasSigned) return;
    const dataUrl = canvas.toDataURL('image/png');
    onConfirmSign(dataUrl);
    onClose();
  };

  const handleConfirmReject = (e: React.FormEvent) => {
    e.preventDefault();
    if (!rejectionReason.trim()) {
      alert('Vui lòng nhập lý do từ chối nghiệm thu!');
      return;
    }
    if (onReject) {
      onReject(rejectionReason.trim());
    }
    onClose();
  };

  return (
    <div className="fixed inset-0 z-50 flex items-end sm:items-center justify-center bg-slate-900/60 backdrop-blur-sm p-0 sm:p-4 transition-all">
      <div className="w-full max-w-md bg-white border border-slate-200 rounded-t-2xl sm:rounded-2xl p-5 shadow-2xl animate-in slide-in-from-bottom duration-300 max-h-[92vh] overflow-y-auto">
        
        {/* Modal Header */}
        <div className="flex items-center justify-between pb-3 border-b border-slate-100">
          <div className="flex items-center gap-2.5">
            <div className="p-2 rounded-lg bg-emerald-50 text-emerald-600 border border-emerald-200">
              <ShieldCheck className="w-5 h-5" />
            </div>
            <div>
              <h3 className="font-extrabold text-slate-900 text-base">{title}</h3>
              <p className="text-xs text-slate-500 font-medium">Mã phiếu: <span className="font-mono text-emerald-700 font-bold">{itemCode}</span></p>
            </div>
          </div>
          <button
            onClick={onClose}
            className="p-1.5 rounded-full text-slate-400 hover:text-slate-700 hover:bg-slate-100 transition"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        {!showRejectForm ? (
          <>
            {/* WORK SUMMARY SECTION (Wireframe 5.E / US-08) */}
            <div className="my-3 p-3.5 rounded-xl bg-slate-50 border border-slate-200 space-y-2 text-xs">
              <div className="font-extrabold text-slate-800 uppercase tracking-wider text-[11px] border-b border-slate-200 pb-1.5 flex items-center justify-between">
                <span className="flex items-center gap-1.5 text-emerald-800">
                  <Wrench className="w-4 h-4 text-emerald-600" /> TÓM TẮT CÔNG VIỆC SỬA CHỮA / BẢO TRÌ
                </span>
                <span className="font-mono text-slate-500 text-[10px]">Wireframe 5.E</span>
              </div>

              <div className="grid grid-cols-2 gap-2 text-[11px]">
                <div>
                  <span className="text-slate-500 block">Thiết bị:</span>
                  <strong className="text-slate-900 font-extrabold">
                    {workSummary?.machineName || 'Máy dập / CNC nhà máy'} ({workSummary?.machineCode || 'MC-102'})
                  </strong>
                </div>
                <div>
                  <span className="text-slate-500 block">Kỹ sư thực hiện:</span>
                  <strong className="text-slate-900 font-bold">
                    {workSummary?.engineerName || 'Trần Minh Đức (ME)'}
                  </strong>
                </div>
              </div>

              <div className="p-2 rounded-xl bg-amber-50 border border-amber-200 text-amber-900 text-[11px] font-bold flex items-center justify-between">
                <span className="flex items-center gap-1">
                  <Clock className="w-3.5 h-3.5 text-amber-600" /> Thời gian dừng máy (Downtime):
                </span>
                <span className="font-mono font-black text-rose-700">{workSummary?.downtimeDuration || '2h 35m'}</span>
              </div>

              <div>
                <span className="text-slate-500 text-[11px] font-bold block mb-1 flex items-center gap-1">
                  <PackageCheck className="w-3.5 h-3.5 text-cyan-600" /> Vật tư & Phụ tùng đã thay thế:
                </span>
                {workSummary?.spareParts && workSummary.spareParts.length > 0 ? (
                  <ul className="space-y-1">
                    {workSummary.spareParts.map((sp, idx) => (
                      <li key={idx} className="text-[11px] text-slate-700 bg-white p-1.5 rounded-lg border border-slate-200 font-medium">
                        • {sp.name} <span className="font-mono text-slate-500">({sp.quantity} cái)</span>
                      </li>
                    ))}
                  </ul>
                ) : (
                  <div className="text-[11px] text-slate-600 bg-white p-1.5 rounded-lg border border-slate-200 font-medium space-y-0.5">
                    <div>• Dầu bôi trơn / Thủy lực 46# (5 lít)</div>
                    <div>• Cụm gioăng làm kín & Van điều áp</div>
                  </div>
                )}
              </div>
            </div>

            {/* Subtitle / Instructions */}
            <div className="my-2 p-2.5 rounded-xl bg-sky-50 border border-sky-200">
              <p className="text-xs text-sky-900 font-medium flex items-center gap-2">
                <PenTool className="w-4 h-4 text-sky-600 shrink-0" />
                {subtitle}
              </p>
            </div>

            {/* Signature Canvas Box (Wireframe 5.E) */}
            <div className="relative my-3 bg-slate-50 border-2 border-dashed border-slate-300 rounded-2xl overflow-hidden shadow-inner">
              <canvas
                ref={canvasRef}
                width={380}
                height={160}
                className="w-full h-40 touch-none cursor-crosshair bg-white"
                onMouseDown={startDrawing}
                onMouseMove={draw}
                onMouseUp={stopDrawing}
                onMouseLeave={stopDrawing}
                onTouchStart={startDrawing}
                onTouchMove={draw}
                onTouchEnd={stopDrawing}
              />
              {!hasSigned && (
                <div className="absolute inset-0 pointer-events-none flex flex-col items-center justify-center text-slate-400">
                  <PenTool className="w-7 h-7 mb-1 animate-pulse text-amber-500" />
                  <span className="text-xs font-medium">Ký tên trực tiếp vào đây để nghiệm thu bàn giao</span>
                </div>
              )}
              {hasSigned && (
                <button
                  onClick={clearCanvas}
                  className="absolute top-2 right-2 px-2.5 py-1 text-xs rounded-lg bg-slate-100 text-slate-700 hover:bg-slate-200 flex items-center gap-1 border border-slate-200 transition font-medium"
                >
                  <RotateCcw className="w-3.5 h-3.5 text-amber-600" /> Xóa chữ ký
                </button>
              )}
            </div>

            {/* Footer Actions */}
            <div className="flex items-center gap-2 pt-1">
              {onReject && (
                <Button
                  type="button"
                  variant="destructive"
                  size="sm"
                  onClick={() => setShowRejectForm(true)}
                  className="px-3"
                >
                  <XCircle className="w-4 h-4" /> ✗ Từ Chối
                </Button>
              )}
              <Button
                type="button"
                variant="outline"
                size="sm"
                onClick={onClose}
                className="flex-1"
              >
                Hủy bỏ
              </Button>
              <Button
                type="button"
                variant="default"
                size="sm"
                disabled={!hasSigned}
                onClick={handleSave}
                className="flex-1"
              >
                <CheckCircle2 className="w-4 h-4" /> ✓ Xác Nhận
              </Button>
            </div>
          </>
        ) : (
          /* Rejection Reason Sub-form */
          <form onSubmit={handleConfirmReject} className="my-3 space-y-3">
            <div className="p-3 rounded-xl bg-rose-50 border border-rose-200 text-xs text-rose-800 flex items-center gap-2">
              <AlertTriangle className="w-4 h-4 text-rose-600 shrink-0" />
              <span>Phiếu sẽ chuyển về trạng thái REJECTED để kỹ sư ME tiếp tục sửa chữa.</span>
            </div>

            <div>
              <label className="block text-xs font-bold text-slate-800 mb-1">Lý do từ chối nghiệm thu:</label>
              <textarea
                rows={3}
                required
                placeholder="Ví dụ: Máy vẫn còn tiếng rít lạch cạch, linh kiện chưa siết chặt..."
                value={rejectionReason}
                onChange={(e) => setRejectionReason(e.target.value)}
                className="w-full bg-slate-50 border border-slate-300 rounded-xl p-3 text-xs text-slate-900 focus:outline-none focus:border-rose-500"
              />
            </div>

            <div className="flex items-center gap-2 pt-1">
              <Button
                type="button"
                variant="outline"
                size="sm"
                onClick={() => setShowRejectForm(false)}
                className="flex-1"
              >
                Quay Lại
              </Button>
              <Button
                type="submit"
                variant="destructive"
                size="sm"
                className="flex-1"
              >
                Xác Nhận Từ Chối
              </Button>
            </div>
          </form>
        )}

      </div>
    </div>
  );
};
