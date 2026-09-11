// Windows process lifetime guard; no UI, authentication or system settings.
// Own CLI descendants die when the collector closes (or loses) this handle.
using System;
using System.ComponentModel;
using System.Runtime.InteropServices;
namespace AIUsawi {
    public sealed class ChildJob : IDisposable {
        [StructLayout(LayoutKind.Sequential)] struct BasicLimits {
            public long ProcessTime, JobTime;
            public uint Flags;
            public UIntPtr MinWorkingSet, MaxWorkingSet;
            public uint ActiveProcesses;
            public UIntPtr Affinity;
            public uint Priority, Scheduling;
        }
        [StructLayout(LayoutKind.Sequential)] struct IoCounters {
            public ulong ReadOperations, WriteOperations, OtherOperations;
            public ulong ReadBytes, WriteBytes, OtherBytes;
        }
        [StructLayout(LayoutKind.Sequential)] struct ExtendedLimits {
            public BasicLimits Basic;
            public IoCounters Io;
            public UIntPtr ProcessMemory, JobMemory, PeakProcessMemory, PeakJobMemory;
        }
        [DllImport("kernel32.dll", CharSet=CharSet.Unicode, SetLastError=true)]
        static extern IntPtr CreateJobObject(IntPtr securityAttributes, string name);
        [DllImport("kernel32.dll", SetLastError=true)]
        static extern bool SetInformationJobObject(IntPtr job, int informationClass, ref ExtendedLimits information, uint length);
        [DllImport("kernel32.dll", SetLastError=true)]
        static extern bool AssignProcessToJobObject(IntPtr job, IntPtr process);
        [DllImport("kernel32.dll")] static extern bool CloseHandle(IntPtr handle);
        IntPtr handle;
        public ChildJob() {
            handle=CreateJobObject(IntPtr.Zero,null);
            if(handle==IntPtr.Zero) throw new Win32Exception(Marshal.GetLastWin32Error());
            var limits=new ExtendedLimits();
            limits.Basic.Flags=0x00002000; // JOB_OBJECT_LIMIT_KILL_ON_JOB_CLOSE
            if(!SetInformationJobObject(handle,9,ref limits,(uint)Marshal.SizeOf(typeof(ExtendedLimits)))) {
                int error=Marshal.GetLastWin32Error();Dispose();throw new Win32Exception(error);
            }
        }
        public void Assign(IntPtr process) {
            if(!AssignProcessToJobObject(handle,process)) throw new Win32Exception(Marshal.GetLastWin32Error());
        }
        public void Dispose() {
            if(handle!=IntPtr.Zero){CloseHandle(handle);handle=IntPtr.Zero;}
        }
    }
}
