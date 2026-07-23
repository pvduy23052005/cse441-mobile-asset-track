'use client';

import React, { useState } from 'react';
import { X, Zap, Camera, QrCode, ArrowRight, ShieldAlert } from 'lucide-react';
import { Machine } from '../types';

interface QRScannerModalProps {
  isOpen: boolean;
  onClose: () => void;
  machines: Machine[];
  onSelectMachine: (machine: Machine) => void;
}

export const QRScannerModal: React.FC<QRScannerModalProps> = ({
  isOpen,
  onClose,
  machines,
  onSelectMachine,
}) => {
  const [flashOn, setFlashOn] = useState(false);
  const [scanning, setScanning] = useState(true);

  if (!isOpen) return null;

  const handleSimulateScan = (machine: Machine) => {
    setScanning(false);
    setTimeout(() => {
      onSelectMachine(machine);
      onClose();
      setScanning(true);
    }, 400);
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-slate-900/70 backdrop-blur-md p-4 animate-in fade-in duration-200">
      <div className="relative w-full max-w-sm bg-white border border-slate-200 rounded-3xl overflow-hidden shadow-2xl flex flex-col">
        
        {/* Camera Header */}
        <div className="px-5 py-4 flex items-center justify-between border-b border-slate-100 bg-white">
          <div className="flex items-center gap-2 text-slate-900 font-extrabold text-sm">
            <QrCode className="w-5 h-5 text-emerald-600" />
            <span>Quét Mã QR Hộ Chiếu Máy</span>
          </div>
          <div className="flex items-center gap-2">
            <button
              onClick={() => setFlashOn(!flashOn)}
              className={`p-2 rounded-full transition ${
                flashOn ? 'bg-amber-400 text-slate-950' : 'bg-slate-100 text-slate-500 hover:text-slate-900'
              }`}
            >
              <Zap className="w-4 h-4" />
            </button>
            <button
              onClick={onClose}
              className="p-2 rounded-full bg-slate-100 text-slate-500 hover:text-slate-900 transition"
            >
              <X className="w-4 h-4" />
            </button>
          </div>
        </div>

        {/* Viewfinder simulation */}
        <div className="relative h-64 bg-slate-900 flex flex-col items-center justify-center overflow-hidden">
          {flashOn && (
            <div className="absolute inset-0 bg-amber-400/20 pointer-events-none transition-all" />
          )}

          {/* Scanner Reticle Frame */}
          <div className="relative w-48 h-48 border-2 border-emerald-400/60 rounded-2xl flex items-center justify-center shadow-[0_0_30px_rgba(16,185,129,0.3)]">
            <div className="absolute -top-1 -left-1 w-5 h-5 border-t-4 border-l-4 border-emerald-400 rounded-tl-lg" />
            <div className="absolute -top-1 -right-1 w-5 h-5 border-t-4 border-r-4 border-emerald-400 rounded-tr-lg" />
            <div className="absolute -bottom-1 -left-1 w-5 h-5 border-b-4 border-l-4 border-emerald-400 rounded-bl-lg" />
            <div className="absolute -bottom-1 -right-1 w-5 h-5 border-b-4 border-r-4 border-emerald-400 rounded-br-lg" />

            {scanning && (
              <div className="absolute inset-x-2 h-0.5 bg-gradient-to-r from-transparent via-emerald-400 to-transparent shadow-[0_0_15px_#34d399] animate-[bounce_2s_infinite]" />
            )}

            <div className="text-center p-3 opacity-90">
              <Camera className="w-8 h-8 text-emerald-400 mx-auto mb-1" />
              <span className="text-[11px] text-slate-300 font-medium">Căn mã QR dán trên thân máy</span>
            </div>
          </div>
        </div>

        {/* Simulator Selection Bar */}
        <div className="p-4 bg-slate-50 border-t border-slate-100">
          <div className="flex items-center gap-1.5 text-xs text-amber-700 font-bold mb-2">
            <ShieldAlert className="w-3.5 h-3.5" />
            <span>Mô phỏng máy ảnh - Chọn nhanh mã máy:</span>
          </div>

          <div className="space-y-2 max-h-48 overflow-y-auto pr-1">
            {machines.map((machine) => (
              <button
                key={machine.id}
                onClick={() => handleSimulateScan(machine)}
                className="w-full p-2.5 rounded-xl bg-white hover:bg-emerald-50/60 border border-slate-200 flex items-center justify-between text-left transition group shadow-xs"
              >
                <div>
                  <div className="flex items-center gap-2">
                    <span className="font-mono text-xs px-2 py-0.5 rounded bg-emerald-100 text-emerald-800 font-extrabold border border-emerald-200">
                      {machine.code}
                    </span>
                    <span className="text-xs text-slate-900 font-bold">{machine.name}</span>
                  </div>
                  <span className="text-[11px] text-slate-500">{machine.location}</span>
                </div>
                <ArrowRight className="w-4 h-4 text-slate-400 group-hover:text-emerald-600 transition-transform group-hover:translate-x-1" />
              </button>
            ))}
          </div>
        </div>

      </div>
    </div>
  );
};
