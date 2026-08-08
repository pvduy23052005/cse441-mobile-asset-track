'use client';

import React, { useState, useEffect } from 'react';
import {
  Smartphone,
  RotateCw,
  Volume2,
  VolumeX,
  Lock,
  Unlock,
  Maximize2,
  Minimize2,
  ZoomIn,
  ZoomOut,
  Sparkles,
  Wifi,
  Radio,
  BatteryCharging,
  Flame,
  AlertTriangle,
  QrCode,
  ShieldCheck,
  Cpu,
  Layers,
  Settings,
  ChevronUp,
  Camera,
  Flashlight,
  CheckCircle2,
  RefreshCw,
} from 'lucide-react';
import { sound } from '../lib/soundEffects';

export type PhoneModel = 'IPHONE_16_PRO' | 'SAMSUNG_S24_ULTRA' | 'PIXEL_9_PRO' | 'MINIMAL' | 'FULLSCREEN';
export type PhoneColor = 'natural' | 'black' | 'desert' | 'blue' | 'emerald';
export type EnvironmentTheme = 'factory' | 'studio' | 'control_room';

interface PhoneDeviceFrameProps {
  children: React.ReactNode;
  activeSosCount?: number;
  activeMachinesCount?: number;
  totalMachinesCount?: number;
  currentUserRole?: string;
  currentUserEmail?: string;
  onOpenQR?: () => void;
  onOpenSOS?: () => void;
  onOpenLogin?: () => void;
}

export const PhoneDeviceFrame: React.FC<PhoneDeviceFrameProps> = ({
  children,
  activeSosCount = 0,
  activeMachinesCount = 4,
  totalMachinesCount = 5,
  currentUserRole = 'OPERATOR',
  currentUserEmail = 'operator.an@factory.com',
  onOpenQR,
  onOpenSOS,
  onOpenLogin,
}) => {
  const [model, setModel] = useState<PhoneModel>('IPHONE_16_PRO');
  const [color, setColor] = useState<PhoneColor>('natural');
  const [envTheme, setEnvTheme] = useState<EnvironmentTheme>('factory');
  const [zoom, setZoom] = useState<number>(100);
  const [isLandscape, setIsLandscape] = useState<boolean>(false);
  const [isLocked, setIsLocked] = useState<boolean>(false);
  const [isMuted, setIsMuted] = useState<boolean>(false);
  const [currentTime, setCurrentTime] = useState<string>('09:41');
  const [currentDateString, setCurrentDateString] = useState<string>('');
  const [isIslandExpanded, setIsIslandExpanded] = useState<boolean>(false);
  const [isNativeMobile, setIsNativeMobile] = useState<boolean>(false);
  const [showToolbar, setShowToolbar] = useState<boolean>(true);

  // Live real-time clock
  useEffect(() => {
    const updateTime = () => {
      const now = new Date();
      setCurrentTime(
        now.toLocaleTimeString('vi-VN', {
          hour: '2-digit',
          minute: '2-digit',
          hour12: false,
        })
      );
      setCurrentDateString(
        now.toLocaleDateString('vi-VN', {
          weekday: 'long',
          day: 'numeric',
          month: 'long',
        })
      );
    };
    updateTime();
    const interval = setInterval(updateTime, 1000);
    return () => clearInterval(interval);
  }, []);

  // Detect if client is already on a mobile screen
  useEffect(() => {
    const checkMobile = () => {
      if (typeof window !== 'undefined') {
        const isMobileScreen = window.innerWidth < 640;
        setIsNativeMobile(isMobileScreen);
        if (isMobileScreen) {
          setModel('FULLSCREEN');
        }
      }
    };
    checkMobile();
    window.addEventListener('resize', checkMobile);
    return () => window.removeEventListener('resize', checkMobile);
  }, []);

  // Sound muting synchronization
  const toggleMute = () => {
    const next = !isMuted;
    setIsMuted(next);
    sound.setMuted(next);
    if (!next) sound.playClick();
  };

  const handlePowerButton = () => {
    const nextLocked = !isLocked;
    setIsLocked(nextLocked);
    sound.playLock(nextLocked);
  };

  const handleActionButton = () => {
    sound.playClick();
    if (onOpenQR) onOpenQR();
  };

  const handleUnlock = () => {
    setIsLocked(false);
    sound.playLock(false);
  };

  // Color Styles for Phone Chassis
  const getColorStyles = () => {
    switch (color) {
      case 'black':
        return {
          frameBg: 'bg-gradient-to-b from-zinc-800 via-zinc-900 to-black',
          frameBorder: 'border-zinc-700/80 shadow-[0_25px_60px_-15px_rgba(0,0,0,0.9),0_0_0_1px_rgba(255,255,255,0.08)_inset]',
          antennaBand: 'bg-zinc-600',
          specular: 'from-zinc-400/20 via-transparent to-zinc-900/40',
          accentName: 'Titan Đen Không Gian (Space Black)',
        };
      case 'desert':
        return {
          frameBg: 'bg-gradient-to-b from-amber-100 via-amber-200 to-amber-300',
          frameBorder: 'border-amber-300/80 shadow-[0_25px_60px_-15px_rgba(180,120,40,0.35),0_0_0_1px_rgba(255,255,255,0.6)_inset]',
          antennaBand: 'bg-amber-400',
          specular: 'from-amber-100/40 via-transparent to-amber-500/20',
          accentName: 'Titan Vàng Sa Mạc (Desert Sand)',
        };
      case 'blue':
        return {
          frameBg: 'bg-gradient-to-b from-slate-800 via-indigo-950 to-slate-900',
          frameBorder: 'border-indigo-800/80 shadow-[0_25px_60px_-15px_rgba(30,50,120,0.5),0_0_0_1px_rgba(147,197,253,0.15)_inset]',
          antennaBand: 'bg-indigo-700',
          specular: 'from-blue-400/25 via-transparent to-indigo-900/40',
          accentName: 'Titan Xanh Biển Sâu (Ocean Blue)',
        };
      case 'emerald':
        return {
          frameBg: 'bg-gradient-to-b from-emerald-950 via-teal-950 to-slate-950',
          frameBorder: 'border-emerald-600/60 shadow-[0_25px_60px_-15px_rgba(5,150,105,0.4),0_0_0_1px_rgba(52,211,153,0.3)_inset]',
          antennaBand: 'bg-emerald-600',
          specular: 'from-emerald-400/30 via-transparent to-teal-900/40',
          accentName: 'Nhà Xưởng Dạ Quang (Factory Emerald)',
        };
      case 'natural':
      default:
        return {
          frameBg: 'bg-gradient-to-b from-stone-200 via-stone-300 to-stone-400',
          frameBorder: 'border-stone-300/90 shadow-[0_25px_60px_-15px_rgba(0,0,0,0.45),0_0_0_1px_rgba(255,255,255,0.7)_inset]',
          antennaBand: 'bg-stone-400',
          specular: 'from-white/50 via-transparent to-stone-600/20',
          accentName: 'Titan Tự Nhiên (Natural Titanium)',
        };
    }
  };

  // Outer Backdrop Styles
  const getEnvBackdrop = () => {
    switch (envTheme) {
      case 'control_room':
        return 'bg-gradient-to-br from-slate-950 via-indigo-950 to-slate-900 text-slate-100';
      case 'studio':
        return 'bg-gradient-to-br from-slate-900 via-zinc-900 to-slate-950 text-slate-100';
      case 'factory':
      default:
        return 'bg-[#0b1120] bg-[radial-gradient(ellipse_80%_80%_at_50%_-20%,rgba(16,185,129,0.15),rgba(255,255,255,0))] text-slate-100';
    }
  };

  const styleConfig = getColorStyles();

  // If in fullscreen mode, render children directly without surrounding mockup frame
  if (model === 'FULLSCREEN') {
    return (
      <div className="min-h-screen bg-slate-100 flex flex-col relative">
        {/* Floating Switcher on top corner if viewed on desktop */}
        {!isNativeMobile && (
          <div className="fixed top-3 right-3 z-50 flex items-center gap-1.5 bg-slate-900/90 backdrop-blur-md text-white px-3 py-1.5 rounded-full shadow-2xl border border-slate-700 text-xs">
            <Smartphone className="w-3.5 h-3.5 text-emerald-400" />
            <span className="font-semibold text-[11px]">Chế Độ Toàn Màn Hình</span>
            <button
              onClick={() => {
                setModel('IPHONE_16_PRO');
                sound.playClick();
              }}
              className="ml-2 px-2 py-0.5 rounded-md bg-emerald-600 hover:bg-emerald-500 text-white text-[10px] font-bold transition shadow-xs"
            >
              📱 Mở Khung Điện Thoại
            </button>
          </div>
        )}
        {children}
      </div>
    );
  }

  return (
    <div className={`min-h-screen w-full flex flex-col justify-between items-center ${getEnvBackdrop()} select-none font-sans overflow-x-hidden transition-colors duration-500`}>
      
      {/* 1. TOP DESKTOP COMPANION BAR (Bảng Điều Khiển Simulator) */}
      <header className="w-full border-b border-white/10 bg-slate-950/70 backdrop-blur-xl px-4 py-2.5 z-40 sticky top-0 flex items-center justify-between shadow-lg">
        
        {/* Logo & System Badge */}
        <div className="flex items-center gap-3">
          <div className="w-8 h-8 rounded-lg bg-gradient-to-tr from-emerald-500 to-teal-400 flex items-center justify-center text-slate-950 font-black text-sm shadow-md shadow-emerald-500/30 ring-2 ring-emerald-400/30">
            AT
          </div>
          <div>
            <div className="flex items-center gap-2">
              <h1 className="text-sm font-black tracking-tight text-white flex items-center gap-1.5">
                <span>AssetTrack Simulator</span>
                <span className="text-[10px] font-mono font-bold px-1.5 py-0.5 rounded bg-emerald-500/20 text-emerald-300 border border-emerald-500/30">
                  v2.4 Mobile
                </span>
              </h1>
            </div>
            <p className="text-[11px] text-slate-400 font-medium">
              Khung Giả Lập Điện Thoại Thông Minh • Hộ Chiếu Thiết Bị Nhà Máy
            </p>
          </div>
        </div>

        {/* Center Controls: Model, Finish, Zoom, Orientation */}
        <div className="hidden lg:flex items-center gap-2 bg-slate-900/90 border border-slate-800 p-1 rounded-xl shadow-inner">
          
          {/* Model Switcher */}
          <div className="flex items-center gap-1 px-1">
            <span className="text-[10px] uppercase font-bold text-slate-400 px-1">Khung:</span>
            <button
              onClick={() => {
                setModel('IPHONE_16_PRO');
                sound.playClick();
              }}
              className={`px-2.5 py-1 rounded-lg text-xs font-bold transition flex items-center gap-1.5 ${
                model === 'IPHONE_16_PRO'
                  ? 'bg-emerald-600 text-white shadow-md shadow-emerald-600/30'
                  : 'text-slate-300 hover:text-white hover:bg-slate-800'
              }`}
            >
              <span>iPhone 16 Pro</span>
            </button>

            <button
              onClick={() => {
                setModel('SAMSUNG_S24_ULTRA');
                sound.playClick();
              }}
              className={`px-2.5 py-1 rounded-lg text-xs font-bold transition flex items-center gap-1.5 ${
                model === 'SAMSUNG_S24_ULTRA'
                  ? 'bg-emerald-600 text-white shadow-md shadow-emerald-600/30'
                  : 'text-slate-300 hover:text-white hover:bg-slate-800'
              }`}
            >
              <span>Galaxy S24</span>
            </button>

            <button
              onClick={() => {
                setModel('PIXEL_9_PRO');
                sound.playClick();
              }}
              className={`px-2.5 py-1 rounded-lg text-xs font-bold transition flex items-center gap-1.5 ${
                model === 'PIXEL_9_PRO'
                  ? 'bg-emerald-600 text-white shadow-md shadow-emerald-600/30'
                  : 'text-slate-300 hover:text-white hover:bg-slate-800'
              }`}
            >
              <span>Pixel 9</span>
            </button>
          </div>

          <div className="w-px h-5 bg-slate-800 my-auto" />

          {/* Color Switcher */}
          <div className="flex items-center gap-1.5 px-2">
            <button
              onClick={() => {
                setColor('natural');
                sound.playClick();
              }}
              className={`w-4 h-4 rounded-full bg-stone-300 border-2 transition ${
                color === 'natural' ? 'border-emerald-400 scale-125 shadow-xs' : 'border-transparent opacity-60 hover:opacity-100'
              }`}
              title="Titan Tự Nhiên"
            />
            <button
              onClick={() => {
                setColor('black');
                sound.playClick();
              }}
              className={`w-4 h-4 rounded-full bg-zinc-900 border-2 transition ${
                color === 'black' ? 'border-emerald-400 scale-125 shadow-xs' : 'border-transparent opacity-60 hover:opacity-100'
              }`}
              title="Titan Đen Không Gian"
            />
            <button
              onClick={() => {
                setColor('desert');
                sound.playClick();
              }}
              className={`w-4 h-4 rounded-full bg-amber-200 border-2 transition ${
                color === 'desert' ? 'border-emerald-400 scale-125 shadow-xs' : 'border-transparent opacity-60 hover:opacity-100'
              }`}
              title="Titan Vàng Sa Mạc"
            />
            <button
              onClick={() => {
                setColor('blue');
                sound.playClick();
              }}
              className={`w-4 h-4 rounded-full bg-indigo-900 border-2 transition ${
                color === 'blue' ? 'border-emerald-400 scale-125 shadow-xs' : 'border-transparent opacity-60 hover:opacity-100'
              }`}
              title="Titan Xanh Biển"
            />
            <button
              onClick={() => {
                setColor('emerald');
                sound.playClick();
              }}
              className={`w-4 h-4 rounded-full bg-emerald-600 border-2 transition ${
                color === 'emerald' ? 'border-emerald-400 scale-125 shadow-xs' : 'border-transparent opacity-60 hover:opacity-100'
              }`}
              title="Nhà Xưởng Dạ Quang"
            />
          </div>

          <div className="w-px h-5 bg-slate-800 my-auto" />

          {/* Zoom Level */}
          <div className="flex items-center gap-1 px-1">
            <button
              onClick={() => {
                setZoom((prev) => Math.max(prev - 10, 70));
                sound.playClick();
              }}
              className="p-1 rounded text-slate-400 hover:text-white hover:bg-slate-800 transition"
              title="Thu nhỏ"
            >
              <ZoomOut className="w-3.5 h-3.5" />
            </button>
            <span className="text-[11px] font-mono font-bold text-slate-300 w-9 text-center">
              {zoom}%
            </span>
            <button
              onClick={() => {
                setZoom((prev) => Math.min(prev + 10, 120));
                sound.playClick();
              }}
              className="p-1 rounded text-slate-400 hover:text-white hover:bg-slate-800 transition"
              title="Phóng to"
            >
              <ZoomIn className="w-3.5 h-3.5" />
            </button>
          </div>

          <div className="w-px h-5 bg-slate-800 my-auto" />

          {/* Rotate Orientation */}
          <button
            onClick={() => {
              setIsLandscape(!isLandscape);
              sound.playClick();
            }}
            className={`p-1.5 rounded-lg text-slate-300 hover:text-white hover:bg-slate-800 transition flex items-center gap-1 text-xs ${
              isLandscape ? 'bg-emerald-600/30 text-emerald-300 border border-emerald-500/40' : ''
            }`}
            title="Xoay hướng thiết bị"
          >
            <RotateCw className="w-3.5 h-3.5" />
            <span className="text-[11px] font-bold">{isLandscape ? 'Ngang' : 'Dọc'}</span>
          </button>
        </div>

        {/* Right Tools: Audio Mute, Lock Screen, Fullscreen, Environment */}
        <div className="flex items-center gap-2">
          
          {/* Audio toggle */}
          <button
            onClick={toggleMute}
            className={`p-2 rounded-lg border transition flex items-center gap-1.5 text-xs font-bold ${
              isMuted
                ? 'bg-slate-900 border-slate-800 text-slate-500'
                : 'bg-emerald-950/60 border-emerald-700/60 text-emerald-300 shadow-xs'
            }`}
            title={isMuted ? 'Bật âm thanh thao tác' : 'Tắt âm thanh'}
          >
            {isMuted ? <VolumeX className="w-4 h-4" /> : <Volume2 className="w-4 h-4" />}
            <span className="hidden sm:inline text-[11px]">{isMuted ? 'Mute' : 'Audio On'}</span>
          </button>

          {/* Lock Screen Toggle */}
          <button
            onClick={handlePowerButton}
            className={`p-2 rounded-lg border transition flex items-center gap-1.5 text-xs font-bold ${
              isLocked
                ? 'bg-amber-950/70 border-amber-600/60 text-amber-300 shadow-xs'
                : 'bg-slate-900 border-slate-800 text-slate-300 hover:text-white'
            }`}
            title="Khóa / Mở khóa màn hình điện thoại"
          >
            {isLocked ? <Lock className="w-4 h-4 text-amber-400" /> : <Unlock className="w-4 h-4" />}
            <span className="hidden sm:inline text-[11px]">{isLocked ? 'Đang Khóa' : 'Khóa Máy'}</span>
          </button>

          {/* Fullscreen Native Toggle */}
          <button
            onClick={() => {
              setModel('FULLSCREEN');
              sound.playClick();
            }}
            className="p-2 rounded-lg bg-slate-900 hover:bg-slate-800 border border-slate-800 text-slate-300 hover:text-white transition flex items-center gap-1.5 text-xs font-bold"
            title="Xem toàn màn hình không viền điện thoại"
          >
            <Maximize2 className="w-4 h-4 text-emerald-400" />
            <span className="hidden sm:inline text-[11px]">Toàn Màn Hình</span>
          </button>
        </div>
      </header>

      {/* 2. CENTER AREA: SMARTPHONE DEVICE MOCKUP */}
      <main className="flex-1 w-full flex items-center justify-center p-4 sm:p-8 relative overflow-auto">
        
        {/* Ambient Factory Mesh & Telemetry HUD Elements */}
        <div className="absolute inset-0 pointer-events-none overflow-hidden flex items-center justify-between px-8 opacity-20 lg:opacity-40">
          <div className="hidden xl:block space-y-4 max-w-xs text-left">
            <div className="p-3 rounded-xl bg-slate-900/80 border border-slate-800 backdrop-blur-md">
              <div className="flex items-center gap-2 text-emerald-400 text-xs font-bold mb-1">
                <Radio className="w-3.5 h-3.5 animate-pulse" />
                <span>REALTIME FACTORY SYNC</span>
              </div>
              <p className="text-[11px] text-slate-300 font-mono">
                Supabase RLS: Active (Workshop WS-01)<br />
                OEE Target: 94.2% • MTTR: 28m<br />
                Đường truyền: WebSocket Realtime
              </p>
            </div>

            <div className="p-3 rounded-xl bg-slate-900/80 border border-slate-800 backdrop-blur-md">
              <div className="flex items-center gap-2 text-amber-400 text-xs font-bold mb-1">
                <AlertTriangle className="w-3.5 h-3.5" />
                <span>PHIẾU SOS KHẨN CẤP</span>
              </div>
              <p className="text-[11px] text-slate-300 font-mono">
                Active SOS: {activeSosCount} sự cố<br />
                Máy phụ trách: {activeMachinesCount}/{totalMachinesCount} máy hoạt động
              </p>
            </div>
          </div>

          <div className="hidden xl:block space-y-4 max-w-xs text-right">
            <div className="p-3 rounded-xl bg-slate-900/80 border border-slate-800 backdrop-blur-md">
              <div className="flex items-center justify-end gap-2 text-blue-400 text-xs font-bold mb-1">
                <span>QUICK HARDWARE KEYS</span>
                <Cpu className="w-3.5 h-3.5" />
              </div>
              <p className="text-[11px] text-slate-300 font-mono">
                • Phím Tác Vụ (Trái): Quét QR<br />
                • Phím Nguồn (Phải): Khóa màn hình<br />
                • Dynamic Island: Chạm mở Dashboard
              </p>
            </div>
          </div>
        </div>

        {/* ============================================================ */}
        {/* SMARTPHONE CHASSIS (KHUNG THIẾT BỊ ĐIỆN THOẠI THỰC TẾ) */}
        {/* ============================================================ */}
        <div
          style={{
            transform: `scale(${zoom / 100})`,
            transformOrigin: 'center center',
          }}
          className={`relative transition-all duration-300 flex items-center justify-center ${
            isLandscape ? 'rotate-90 my-24' : ''
          }`}
        >
          {/* Physical Side Buttons (Left Side: Action Button, Volume Up, Volume Down) */}
          <div className="absolute -left-[5px] top-28 flex flex-col gap-3 z-0">
            {/* Action Button */}
            <button
              onClick={handleActionButton}
              className="w-[5px] h-8 rounded-l-md bg-gradient-to-r from-stone-400 to-stone-500 hover:w-[7px] active:translate-x-[2px] transition-all shadow-md cursor-pointer group"
              title="Phím Tác Vụ (Action Button) - Quét QR nhanh"
            />
            {/* Volume Up */}
            <button
              onClick={() => {
                sound.playClick();
                setZoom((z) => Math.min(z + 5, 120));
              }}
              className="w-[5px] h-12 rounded-l-md bg-gradient-to-r from-stone-400 to-stone-500 hover:w-[7px] active:translate-x-[2px] transition-all shadow-md cursor-pointer"
              title="Tăng âm lượng / Phóng to"
            />
            {/* Volume Down */}
            <button
              onClick={() => {
                sound.playClick();
                setZoom((z) => Math.max(z - 5, 75));
              }}
              className="w-[5px] h-12 rounded-l-md bg-gradient-to-r from-stone-400 to-stone-500 hover:w-[7px] active:translate-x-[2px] transition-all shadow-md cursor-pointer"
              title="Giảm âm lượng / Thu nhỏ"
            />
          </div>

          {/* Physical Side Buttons (Right Side: Power / Sleep Button) */}
          <div className="absolute -right-[5px] top-36 z-0">
            <button
              onClick={handlePowerButton}
              className="w-[5px] h-16 rounded-r-md bg-gradient-to-l from-stone-400 to-stone-500 hover:w-[7px] active:-translate-x-[2px] transition-all shadow-md cursor-pointer"
              title="Phím Nguồn (Power / Lock Screen)"
            />
          </div>

          {/* Outer Phone Bezel Container */}
          <div
            className={`relative p-[11px] sm:p-[13px] ${styleConfig.frameBg} ${styleConfig.frameBorder} transition-all duration-300 ${
              model === 'SAMSUNG_S24_ULTRA'
                ? 'rounded-[32px] w-[410px] h-[860px]'
                : model === 'PIXEL_9_PRO'
                ? 'rounded-[46px] w-[405px] h-[855px]'
                : 'rounded-[54px] w-[405px] h-[855px]'
            }`}
          >
            {/* Realistic Chamfer Metallic Reflection Border */}
            <div className={`absolute inset-0 rounded-[inherit] pointer-events-none bg-gradient-to-tr ${styleConfig.specular}`} />

            {/* Inner Phone Screen Display (Màn Hình Điện Thoại Cảm Ứng) */}
            <div
              className={`relative w-full h-full bg-slate-900 overflow-hidden flex flex-col shadow-inner ${
                model === 'SAMSUNG_S24_ULTRA'
                  ? 'rounded-[24px]'
                  : model === 'PIXEL_9_PRO'
                  ? 'rounded-[36px]'
                  : 'rounded-[44px]'
              }`}
            >
              {/* TOP STATUS BAR (Thanh Trạng Thái Điện Thoại) */}
              <div className="sticky top-0 z-40 w-full bg-white/95 backdrop-blur-md px-6 pt-3 pb-1 flex items-center justify-between text-slate-900 border-b border-slate-100">
                
                {/* Time Display */}
                <div className="w-14 text-left">
                  <span className="text-[13px] font-bold tracking-tight font-sans">
                    {currentTime}
                  </span>
                </div>

                {/* DYNAMIC ISLAND / CAMERA NOTCH */}
                {model === 'IPHONE_16_PRO' ? (
                  <div
                    onClick={() => {
                      setIsIslandExpanded(!isIslandExpanded);
                      sound.playClick();
                    }}
                    className={`cursor-pointer transition-all duration-300 ease-out bg-black text-white rounded-full flex items-center justify-between px-2.5 shadow-lg ${
                      isIslandExpanded
                        ? 'w-64 h-11 bg-slate-950 ring-2 ring-emerald-500/50'
                        : 'w-28 h-6 hover:scale-105'
                    }`}
                  >
                    {!isIslandExpanded ? (
                      <>
                        {/* Compact Notch Mode */}
                        <div className="w-2.5 h-2.5 rounded-full bg-zinc-900 border border-zinc-800 flex items-center justify-center">
                          <div className="w-1 h-1 rounded-full bg-indigo-950/80" />
                        </div>
                        {activeSosCount > 0 ? (
                          <span className="text-[9px] font-bold text-rose-400 flex items-center gap-1 animate-pulse">
                            <span className="w-1.5 h-1.5 rounded-full bg-rose-500" />
                            {activeSosCount} SOS
                          </span>
                        ) : (
                          <span className="text-[9px] font-mono text-emerald-400 flex items-center gap-1">
                            <span className="w-1.5 h-1.5 rounded-full bg-emerald-500 animate-ping" />
                            94.2%
                          </span>
                        )}
                        <div className="w-2 h-2 rounded-full bg-emerald-500/60" />
                      </>
                    ) : (
                      /* Expanded Dynamic Island Widget */
                      <div className="w-full flex items-center justify-between px-1 text-[11px] animate-in fade-in zoom-in-95 duration-200">
                        <div className="flex items-center gap-2">
                          <div className="w-6 h-6 rounded-full bg-emerald-500/20 flex items-center justify-center text-emerald-400">
                            <Cpu className="w-3.5 h-3.5" />
                          </div>
                          <div>
                            <div className="text-[10px] font-bold text-white leading-tight">AssetTrack Realtime</div>
                            <div className="text-[9px] text-emerald-400 leading-tight">OEE 94.2% • {activeMachinesCount}/{totalMachinesCount} Active</div>
                          </div>
                        </div>
                        <button
                          onClick={(e) => {
                            e.stopPropagation();
                            setIsIslandExpanded(false);
                            if (onOpenQR) onOpenQR();
                          }}
                          className="px-2 py-0.5 rounded-full bg-emerald-600 hover:bg-emerald-500 text-white font-bold text-[9px] flex items-center gap-1 shadow-xs"
                        >
                          <QrCode className="w-2.5 h-2.5" />
                          <span>Quét QR</span>
                        </button>
                      </div>
                    )}
                  </div>
                ) : (
                  /* Android Punch-Hole Camera */
                  <div className="w-3.5 h-3.5 rounded-full bg-black border border-zinc-800 flex items-center justify-center shadow-inner">
                    <div className="w-1 h-1 rounded-full bg-indigo-900/60" />
                  </div>
                )}

                {/* Right Status Icons: 5G, Wi-Fi, Battery */}
                <div className="w-14 flex items-center justify-end gap-1.5 text-slate-800">
                  <span className="text-[10px] font-bold font-mono">5G</span>
                  <Wifi className="w-3.5 h-3.5" />
                  <div className="flex items-center gap-0.5">
                    <div className="w-5 h-2.5 rounded-sm border border-slate-700 p-0.5 flex items-center">
                      <div className="h-full w-4/5 rounded-xs bg-emerald-600" />
                    </div>
                  </div>
                </div>
              </div>

              {/* PHONE SCREEN CONTENT VIEWPORT */}
              <div className="relative flex-1 bg-slate-50 overflow-y-auto overflow-x-hidden flex flex-col">
                
                {/* Real-Time Mobile Content */}
                {children}

                {/* LOCK SCREEN OVERLAY IF LOCKED */}
                {isLocked && (
                  <div
                    onClick={handleUnlock}
                    className="absolute inset-0 z-50 bg-gradient-to-b from-slate-900/90 via-slate-950/95 to-black text-white p-6 flex flex-col justify-between backdrop-blur-xl animate-in fade-in duration-300 cursor-pointer"
                  >
                    {/* Top Lock status */}
                    <div className="flex flex-col items-center pt-8">
                      <Lock className="w-6 h-6 text-amber-400 mb-2 animate-bounce" />
                      <div className="text-[13px] font-medium text-slate-300 capitalize">{currentDateString}</div>
                      <div className="text-6xl font-extralight tracking-tight text-white mt-1 font-sans">
                        {currentTime}
                      </div>
                    </div>

                    {/* Factory Alert Lock Notification */}
                    <div className="space-y-2">
                      <div className="p-3.5 rounded-2xl bg-white/10 border border-white/10 backdrop-blur-md text-left shadow-xl">
                        <div className="flex items-center justify-between text-xs font-bold text-emerald-400 mb-1">
                          <span className="flex items-center gap-1.5">
                            <span className="w-2 h-2 rounded-full bg-emerald-400 animate-ping" />
                            AssetTrack Mobile
                          </span>
                          <span className="text-[10px] text-slate-400">Vừa xong</span>
                        </div>
                        <p className="text-xs font-semibold text-white">Hệ Thống Nhà Máy Vận Hành Ổn Định</p>
                        <p className="text-[11px] text-slate-300 mt-0.5">
                          {activeMachinesCount}/{totalMachinesCount} Máy đang chạy • Chạm để mở khóa ứng dụng
                        </p>
                      </div>

                      {activeSosCount > 0 && (
                        <div className="p-3.5 rounded-2xl bg-rose-500/20 border border-rose-500/30 backdrop-blur-md text-left shadow-xl animate-pulse">
                          <div className="flex items-center justify-between text-xs font-bold text-rose-400 mb-1">
                            <span className="flex items-center gap-1.5">
                              <AlertTriangle className="w-3.5 h-3.5" />
                              CẢNH BÁO SOS KHẨN CẤP
                            </span>
                            <span className="text-[10px] text-rose-300">Cần xử lý</span>
                          </div>
                          <p className="text-xs font-semibold text-white">Phát hiện {activeSosCount} sự cố dừng máy</p>
                        </div>
                      )}
                    </div>

                    {/* Bottom Quick Tools on Lockscreen */}
                    <div className="flex flex-col items-center gap-4 pb-4">
                      <div className="flex items-center justify-between w-full px-4">
                        <button
                          onClick={(e) => {
                            e.stopPropagation();
                            sound.playClick();
                          }}
                          className="w-11 h-11 rounded-full bg-white/15 hover:bg-white/25 flex items-center justify-center text-white backdrop-blur-md shadow-lg transition"
                        >
                          <Flashlight className="w-5 h-5" />
                        </button>
                        <button
                          onClick={(e) => {
                            e.stopPropagation();
                            handleUnlock();
                            if (onOpenQR) onOpenQR();
                          }}
                          className="w-11 h-11 rounded-full bg-white/15 hover:bg-white/25 flex items-center justify-center text-white backdrop-blur-md shadow-lg transition"
                        >
                          <Camera className="w-5 h-5" />
                        </button>
                      </div>

                      <div className="flex items-center gap-1.5 text-xs text-slate-400 font-medium animate-pulse">
                        <ChevronUp className="w-4 h-4" />
                        <span>Vuốt lên hoặc chạm để mở khóa</span>
                      </div>
                    </div>
                  </div>
                )}
              </div>

              {/* BOTTOM HOME INDICATOR BAR (Thanh Vuốt Home iPhone) */}
              <div className="sticky bottom-0 z-40 w-full bg-white/95 backdrop-blur-md py-1.5 flex items-center justify-center border-t border-slate-100/60">
                <div
                  onClick={() => sound.playClick()}
                  className="w-32 h-1 rounded-full bg-slate-400 hover:bg-slate-700 active:scale-95 transition-all cursor-pointer shadow-xs"
                  title="Thanh Điều Hướng Home"
                />
              </div>

            </div>
          </div>
        </div>

      </main>

      {/* 3. BOTTOM FOOTER INFO */}
      <footer className="w-full border-t border-white/10 bg-slate-950/80 backdrop-blur-md px-4 py-2 flex flex-wrap items-center justify-between text-slate-400 text-xs z-30">
        <div className="flex items-center gap-2">
          <span className="w-2 h-2 rounded-full bg-emerald-400 animate-ping" />
          <span className="text-[11px] font-medium text-slate-300">
            Màu sắc vỏ máy: <strong className="text-white">{styleConfig.accentName}</strong>
          </span>
        </div>

        <div className="flex items-center gap-4 text-[11px]">
          <span>Phân xưởng: <strong>WS-01 May Mặc</strong></span>
          <span>Tài khoản: <strong className="text-emerald-400">{currentUserEmail}</strong></span>
          <span>Vai trò: <strong className="text-amber-400">{currentUserRole}</strong></span>
        </div>
      </footer>

    </div>
  );
};
