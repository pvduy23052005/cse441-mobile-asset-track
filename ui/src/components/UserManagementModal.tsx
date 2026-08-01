'use client';

import React, { useState } from 'react';
import { X, Users, UserPlus, FileSpreadsheet, CheckCircle2, ShieldCheck, Upload, Download, Trash2 } from 'lucide-react';

interface Employee {
  id: string;
  fullName: string;
  email: string;
  employeeCode: string;
  role: 'OPERATOR' | 'ME_ENGINEER';
}

interface UserManagementModalProps {
  isOpen: boolean;
  onClose: () => void;
  workshopName?: string;
}

export const UserManagementModal: React.FC<UserManagementModalProps> = ({
  isOpen,
  onClose,
  workshopName = 'Phân Xưởng Ép Nhựa 1',
}) => {
  const [activeTab, setActiveTab] = useState<'LIST' | 'MANUAL' | 'EXCEL'>('LIST');

  // Initial Mock Employee List
  const [employees, setEmployees] = useState<Employee[]>([
    { id: '1', fullName: 'Nguyễn Văn An', email: 'an.nguyen@factory.com', employeeCode: 'NV-101', role: 'OPERATOR' },
    { id: '2', fullName: 'Trần Minh Đức', email: 'duc.tran@factory.com', employeeCode: 'ME-204', role: 'ME_ENGINEER' },
    { id: '3', fullName: 'Lê Hoàng Nam', email: 'nam.le@factory.com', employeeCode: 'NV-105', role: 'OPERATOR' },
  ]);

  // Form Manual State
  const [fullName, setFullName] = useState('');
  const [email, setEmail] = useState('');
  const [employeeCode, setEmployeeCode] = useState('');
  const [role, setRole] = useState<'OPERATOR' | 'ME_ENGINEER'>('OPERATOR');

  // Excel Upload State
  const [selectedFileName, setSelectedFileName] = useState<string | null>(null);
  const [previewList, setPreviewList] = useState<Employee[]>([]);
  const [isImported, setIsImported] = useState(false);

  if (!isOpen) return null;

  const handleAddManual = (e: React.FormEvent) => {
    e.preventDefault();
    if (!fullName.trim() || !email.trim()) {
      alert('Vui lòng điền đầy đủ Họ tên và Email!');
      return;
    }

    const newEmp: Employee = {
      id: Date.now().toString(),
      fullName,
      email,
      employeeCode: employeeCode || `NV-${Math.floor(100 + Math.random() * 900)}`,
      role,
    };

    setEmployees((prev) => [newEmp, ...prev]);
    setFullName('');
    setEmail('');
    setEmployeeCode('');
    alert(`Đã cấp tài khoản thành công cho nhân viên: ${fullName}`);
    setActiveTab('LIST');
  };

  const handleSimulateExcelSelect = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (file) {
      setSelectedFileName(file.name);
      // Simulate reading 3 employees from Excel file
      setPreviewList([
        { id: 'ex-1', fullName: 'Phạm Quốc Bảo', email: 'bao.pham@factory.com', employeeCode: 'NV-108', role: 'OPERATOR' },
        { id: 'ex-2', fullName: 'Vũ Thị Hoa', email: 'hoa.vu@factory.com', employeeCode: 'ME-209', role: 'ME_ENGINEER' },
        { id: 'ex-3', fullName: 'Đặng Tuấn Anh', email: 'anh.dang@factory.com', employeeCode: 'NV-112', role: 'OPERATOR' },
      ]);
      setIsImported(false);
    }
  };

  const handleConfirmImportExcel = () => {
    if (previewList.length === 0) return;
    setEmployees((prev) => [...previewList, ...prev]);
    setIsImported(true);
    alert(`Đã import thành công ${previewList.length} nhân viên từ file Excel!`);
    setPreviewList([]);
    setSelectedFileName(null);
    setActiveTab('LIST');
  };

  const handleRemoveEmployee = (id: string) => {
    if (confirm('Bạn có chắc chắn muốn vô hiệu hóa tài khoản nhân viên này?')) {
      setEmployees((prev) => prev.filter((emp) => emp.id !== id));
    }
  };

  return (
    <div className="fixed inset-0 z-50 flex items-end sm:items-center justify-center bg-slate-900/60 backdrop-blur-sm p-0 sm:p-4 animate-in fade-in duration-200">
      <div className="w-full max-w-md bg-white border border-slate-200 rounded-t-2xl sm:rounded-2xl overflow-hidden shadow-2xl animate-in slide-in-from-bottom duration-300">
        
        {/* Header */}
        <div className="p-4 bg-slate-50 border-b border-slate-200 flex items-center justify-between">
          <div className="flex items-center gap-2.5">
            <div className="p-2 rounded-lg bg-amber-50 text-amber-700 border border-amber-200">
              <Users className="w-5 h-5" />
            </div>
            <div>
              <h2 className="font-extrabold text-slate-900 text-sm">Quản Lý Nhân Sự Phân Xưởng</h2>
              <p className="text-[11px] text-slate-500 font-medium">{workshopName}</p>
            </div>
          </div>
          <button
            onClick={onClose}
            className="p-1.5 rounded-full text-slate-400 hover:text-slate-700 hover:bg-slate-200/60 transition"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* Tab Navigation */}
        <div className="flex border-b border-slate-200 bg-slate-100/70 p-1 gap-1">
          <button
            onClick={() => setActiveTab('LIST')}
            className={`flex-1 py-2 text-xs font-extrabold rounded-lg transition flex items-center justify-center gap-1.5 ${
              activeTab === 'LIST'
                ? 'bg-white text-slate-900 shadow-xs border border-slate-200/80'
                : 'text-slate-500 hover:text-slate-800'
            }`}
          >
            <Users className="w-3.5 h-3.5" /> Danh Sách ({employees.length})
          </button>
          <button
            onClick={() => setActiveTab('MANUAL')}
            className={`flex-1 py-2 text-xs font-extrabold rounded-lg transition flex items-center justify-center gap-1.5 ${
              activeTab === 'MANUAL'
                ? 'bg-white text-slate-900 shadow-xs border border-slate-200/80'
                : 'text-slate-500 hover:text-slate-800'
            }`}
          >
            <UserPlus className="w-3.5 h-3.5 text-amber-600" /> Thêm Tay
          </button>
          <button
            onClick={() => setActiveTab('EXCEL')}
            className={`flex-1 py-2 text-xs font-extrabold rounded-lg transition flex items-center justify-center gap-1.5 ${
              activeTab === 'EXCEL'
                ? 'bg-white text-slate-900 shadow-xs border border-slate-200/80'
                : 'text-slate-500 hover:text-slate-800'
            }`}
          >
            <FileSpreadsheet className="w-3.5 h-3.5 text-emerald-600" /> Import Excel
          </button>
        </div>

        {/* Body Content */}
        <div className="p-4 max-h-[75vh] overflow-y-auto space-y-4">
          
          {/* TAB 1: DANH SÁCH NHÂN VIÊN */}
          {activeTab === 'LIST' && (
            <div className="space-y-2.5">
              <div className="flex items-center justify-between text-[11px] text-slate-500 font-bold px-1">
                <span>Họ tên & Email</span>
                <span>Vai trò & Thao tác</span>
              </div>

              {employees.length === 0 ? (
                <div className="p-6 text-center text-xs text-slate-400 border border-dashed border-slate-200 rounded-xl">
                  Chưa có nhân viên nào thuộc phân xưởng này.
                </div>
              ) : (
                employees.map((emp) => (
                  <div
                    key={emp.id}
                    className="p-3 rounded-xl bg-slate-50 border border-slate-200 flex items-center justify-between text-xs"
                  >
                    <div>
                      <div className="flex items-center gap-2">
                        <span className="font-bold text-slate-900">{emp.fullName}</span>
                        <span className="font-mono text-[10px] text-slate-500 bg-slate-200 px-1.5 py-0.5 rounded">
                          {emp.employeeCode}
                        </span>
                      </div>
                      <span className="text-[11px] text-slate-500 block mt-0.5">{emp.email}</span>
                    </div>

                    <div className="flex items-center gap-2">
                      {emp.role === 'OPERATOR' ? (
                        <span className="px-2 py-0.5 rounded-full text-[10px] font-extrabold bg-sky-100 text-sky-800 border border-sky-200">
                          Operator
                        </span>
                      ) : (
                        <span className="px-2 py-0.5 rounded-full text-[10px] font-extrabold bg-amber-100 text-amber-800 border border-amber-200">
                          ME Engineer
                        </span>
                      )}

                      <button
                        onClick={() => handleRemoveEmployee(emp.id)}
                        className="p-1 rounded-lg text-slate-400 hover:text-rose-600 hover:bg-rose-50 transition"
                        title="Vô hiệu hóa"
                      >
                        <Trash2 className="w-3.5 h-3.5" />
                      </button>
                    </div>
                  </div>
                ))
              )}
            </div>
          )}

          {/* TAB 2: THÊM NHÂN VIÊN THỦ CÔNG */}
          {activeTab === 'MANUAL' && (
            <form onSubmit={handleAddManual} className="space-y-3">
              <div>
                <label className="text-[11px] font-extrabold uppercase text-slate-600 block mb-1">
                  Họ và tên <span className="text-rose-600">*</span>
                </label>
                <input
                  type="text"
                  placeholder="e.g. Nguyễn Văn An"
                  value={fullName}
                  onChange={(e) => setFullName(e.target.value)}
                  className="w-full bg-slate-50 border border-slate-300 rounded-xl px-3 py-2 text-xs font-bold text-slate-900 focus:outline-none focus:border-amber-500"
                  required
                />
              </div>

              <div>
                <label className="text-[11px] font-extrabold uppercase text-slate-600 block mb-1">
                  Địa chỉ Email <span className="text-rose-600">*</span>
                </label>
                <input
                  type="email"
                  placeholder="e.g. an.nguyen@factory.com"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  className="w-full bg-slate-50 border border-slate-300 rounded-xl px-3 py-2 text-xs font-bold text-slate-900 focus:outline-none focus:border-amber-500"
                  required
                />
              </div>

              <div>
                <label className="text-[11px] font-extrabold uppercase text-slate-600 block mb-1">
                  Mã nhân viên (Không bắt buộc)
                </label>
                <input
                  type="text"
                  placeholder="e.g. NV-101"
                  value={employeeCode}
                  onChange={(e) => setEmployeeCode(e.target.value)}
                  className="w-full bg-slate-50 border border-slate-300 rounded-xl px-3 py-2 text-xs font-bold font-mono text-slate-900 focus:outline-none focus:border-amber-500"
                />
              </div>

              <div>
                <label className="text-[11px] font-extrabold uppercase text-slate-600 block mb-1">
                  Vai trò phân gán <span className="text-rose-600">*</span>
                </label>
                <div className="grid grid-cols-2 gap-2">
                  <button
                    type="button"
                    onClick={() => setRole('OPERATOR')}
                    className={`p-2.5 rounded-xl border text-xs font-extrabold flex flex-col items-center gap-1 transition ${
                      role === 'OPERATOR'
                        ? 'bg-sky-50 border-sky-400 text-sky-900 ring-2 ring-sky-300/50'
                        : 'bg-slate-50 border-slate-200 text-slate-600'
                    }`}
                  >
                    <span>👷‍♂️ Operator</span>
                    <span className="text-[10px] font-normal text-slate-500">Công nhân vận hành</span>
                  </button>

                  <button
                    type="button"
                    onClick={() => setRole('ME_ENGINEER')}
                    className={`p-2.5 rounded-xl border text-xs font-extrabold flex flex-col items-center gap-1 transition ${
                      role === 'ME_ENGINEER'
                        ? 'bg-amber-50 border-amber-400 text-amber-900 ring-2 ring-amber-300/50'
                        : 'bg-slate-50 border-slate-200 text-slate-600'
                    }`}
                  >
                    <span>🛠️ ME Engineer</span>
                    <span className="text-[10px] font-normal text-slate-500">Kỹ sư cơ điện bảo trì</span>
                  </button>
                </div>
              </div>

              <div className="pt-2">
                <button
                  type="submit"
                  className="w-full py-2.5 rounded-xl bg-amber-500 hover:bg-amber-600 text-white text-xs font-extrabold flex items-center justify-center gap-1.5 shadow-xs transition"
                >
                  <UserPlus className="w-4 h-4" /> Tạo Tài Khoản Nhân Viên
                </button>
              </div>
            </form>
          )}

          {/* TAB 3: IMPORT HÀNG LOẠT BẰNG EXCEL */}
          {activeTab === 'EXCEL' && (
            <div className="space-y-3.5">
              <div className="p-3 rounded-xl bg-slate-50 border border-slate-200 space-y-2">
                <div className="flex items-center justify-between">
                  <span className="text-xs font-extrabold text-slate-800">Tải File Excel Mẫu (.xlsx)</span>
                  <button
                    type="button"
                    onClick={() => alert('Đã tải xuống file mẫu: Mau_Nhan_Vien_AssetTrack.xlsx')}
                    className="px-2.5 py-1 rounded-lg bg-emerald-100 hover:bg-emerald-200 text-emerald-800 text-[11px] font-bold flex items-center gap-1 transition"
                  >
                    <Download className="w-3.5 h-3.5" /> File Mẫu
                  </button>
                </div>
                <p className="text-[11px] text-slate-500 leading-snug">
                  File mẫu bao gồm các cột: <code>Full_Name</code>, <code>Email</code>, <code>Employee_Code</code>, <code>Role</code> (OPERATOR / ME_ENGINEER).
                </p>
              </div>

              {/* Upload Zone */}
              <div className="relative border-2 border-dashed border-slate-300 hover:border-emerald-500 rounded-xl p-4 text-center bg-slate-50 hover:bg-emerald-50/40 transition group cursor-pointer">
                <input
                  type="file"
                  accept=".xlsx,.xls,.csv"
                  onChange={handleSimulateExcelSelect}
                  className="absolute inset-0 w-full h-full opacity-0 cursor-pointer"
                />
                <div className="flex flex-col items-center gap-1.5">
                  <div className="p-2.5 rounded-full bg-emerald-100 text-emerald-700 group-hover:scale-110 transition">
                    <Upload className="w-5 h-5" />
                  </div>
                  <span className="text-xs font-extrabold text-slate-800">
                    {selectedFileName ? selectedFileName : 'Kéo thả hoặc Bấm để chọn File Excel'}
                  </span>
                  <span className="text-[10px] text-slate-400 font-medium">Định dạng hỗ trợ: .xlsx, .xls, .csv (&lt; 10MB)</span>
                </div>
              </div>

              {/* Preview Table */}
              {previewList.length > 0 && (
                <div className="space-y-2">
                  <div className="flex items-center justify-between text-xs font-extrabold text-slate-800">
                    <span>Xem Trước ({previewList.length} Nhân Viên)</span>
                    <span className="text-[10px] text-emerald-600 bg-emerald-50 px-2 py-0.5 rounded border border-emerald-200">
                      Sẵn sàng Import
                    </span>
                  </div>

                  <div className="space-y-1.5">
                    {previewList.map((item, idx) => (
                      <div key={idx} className="p-2.5 rounded-lg bg-slate-100/80 border border-slate-200 text-[11px] flex items-center justify-between">
                        <div>
                          <span className="font-bold text-slate-900">{item.fullName}</span>
                          <span className="text-slate-500 block text-[10px]">{item.email}</span>
                        </div>
                        <span className="font-mono text-[10px] font-bold text-slate-600 bg-white px-2 py-0.5 rounded border border-slate-200">
                          {item.role}
                        </span>
                      </div>
                    ))}
                  </div>

                  <button
                    type="button"
                    onClick={handleConfirmImportExcel}
                    className="w-full py-2.5 rounded-xl bg-emerald-600 hover:bg-emerald-700 text-white text-xs font-extrabold flex items-center justify-center gap-1.5 shadow-xs transition"
                  >
                    <CheckCircle2 className="w-4 h-4" /> Xác Nhận Import Hàng Loạt Vào Phân Xưởng
                  </button>
                </div>
              )}
            </div>
          )}

          {/* Security Note */}
          <div className="p-2.5 rounded-xl bg-slate-100 border border-slate-200 text-[11px] text-slate-500 flex items-center gap-2">
            <ShieldCheck className="w-4 h-4 text-slate-400 shrink-0" />
            <span>Tài khoản mới sẽ tự động được gán vào <strong>{workshopName}</strong> (Bảo mật RLS).</span>
          </div>

        </div>

      </div>
    </div>
  );
};
