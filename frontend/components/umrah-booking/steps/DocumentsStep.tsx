// Step 5: Documents Component - Simple ZIP file upload (similar to group booking)

import React, { useState, useRef } from 'react';
import { Card } from '@/components/ui/card';
import { UploadCloud, File, X, Eye, FileText, ShieldCheck } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { toast } from 'sonner';
import { Step5Data, Step6Data, Step1Data, Step3Data } from '@/lib/umrah/types';
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from '@/components/ui/dialog';
import Image from 'next/image';
import { cn } from '@/lib/utils';

interface DocumentsStepProps {
  data: Step5Data | Step6Data;
  step1Data: Step1Data;
  step3Data: Step3Data;
  onChange: (data: Partial<Step5Data> | Partial<Step6Data>) => void;
  onStep1DataChange?: (data: Partial<Step1Data>) => void;
  disabled?: boolean;
}

export const DocumentsStep: React.FC<DocumentsStepProps> = ({
  data,
  step1Data,
  step3Data,
  onChange,
  disabled = false,
}) => {
  const [isDragging, setIsDragging] = useState(false);
  const [showSample, setShowSample] = useState(false);
  const fileInputRef = useRef<HTMLInputElement>(null);
  
  // Get the uploaded ZIP file from step5Data or step6Data
  const zipFile = (data as Step5Data | Step6Data).panCardZipFile || null;

  // Determine hasGroupNumber and accommodationType
  const hasGroupNumber = step1Data.bookingMode === 'group_number';
  const accommodationType = step3Data.accommodationType;

  // Generate dynamic instructions based on conditions
  const getInstructions = () => {
    const baseWarning = "All documents should be inside a ZIP file. Be sure all documents are attached, else the booking will be canceled by authorized personals.";
    
    let requiredDocs: string[] = [];

    if (hasGroupNumber && accommodationType === 'hotel') {
      requiredDocs = ['PAN card of all passengers'];
    } else if (hasGroupNumber && accommodationType === 'iqama') {
      requiredDocs = ['PAN card of all passengers', 'Iqama holder Iqama copy'];
    } else if (!hasGroupNumber && accommodationType === 'hotel') {
      requiredDocs = [
        'Passport front and back of all passengers',
        'PAN card of all passengers',
        'Passport sized photo of each passenger'
      ];
    } else if (!hasGroupNumber && accommodationType === 'iqama') {
      requiredDocs = [
        'Passport front and back of all passengers',
        'PAN card of all passengers',
        'Passport sized photo of each passenger',
        'Iqama holder Iqama copy'
      ];
    } else {
      // Fallback if accommodationType is not set yet
      requiredDocs = [
        'All required documents as per your booking type'
      ];
    }

    return { baseWarning, requiredDocs };
  };

  const { baseWarning, requiredDocs } = getInstructions();

  const handleFileSelect = (file: File) => {
    // Validate file type - accept ZIP files
    const isValidZip = file.type === 'application/zip' || file.name.toLowerCase().endsWith('.zip');
    
    if (!isValidZip) {
      toast.error('Please upload a ZIP file (.zip) containing all documents');
      return;
    }

    // No max size validation - removed as per user requirement

    // Store the file in step5Data
    onChange({ panCardZipFile: file });
  };

  const handleDrop = (e: React.DragEvent<HTMLDivElement>) => {
    e.preventDefault();
    setIsDragging(false);

    const files = e.dataTransfer.files;
    if (files.length > 0) {
      handleFileSelect(files[0]);
    }
  };

  const handleDragOver = (e: React.DragEvent<HTMLDivElement>) => {
    e.preventDefault();
    setIsDragging(true);
  };

  const handleDragLeave = (e: React.DragEvent<HTMLDivElement>) => {
    e.preventDefault();
    setIsDragging(false);
  };

  const handleFileInputChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const files = e.target.files;
    if (files && files.length > 0) {
      handleFileSelect(files[0]);
    }
  };

  const handleRemoveFile = () => {
    onChange({ panCardZipFile: null });
    if (fileInputRef.current) {
      fileInputRef.current.value = '';
    }
  };

  return (
    <div className="space-y-6 animate-in fade-in duration-500">
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 mb-4 border-b border-secondary/10 pb-4">
        <div>
          <h4 className="text-lg font-bold text-primary uppercase tracking-tight">Documents Upload</h4>
          <p className="text-[10px] text-muted-foreground font-medium mt-0.5 opacity-60">
            Upload a ZIP file containing all required documents
          </p>
        </div>
        <Dialog open={showSample} onOpenChange={setShowSample}>
          <DialogTrigger asChild>
            <Button
              type="button"
              className="h-9 px-4 rounded-lg bg-white border border-secondary/20 text-primary font-bold uppercase tracking-wider shadow-sm hover:bg-secondary hover:text-primary transition-all active:scale-95 flex items-center gap-2 group text-[9px]"
            >
              <Eye className="w-3.5 h-3.5 text-secondary group-hover:text-primary transition-colors" />
              Show Sample
            </Button>
          </DialogTrigger>
          <DialogContent className="max-w-4xl max-h-[90vh] overflow-auto rounded-2xl border-0 shadow-2xl p-0">
            <DialogHeader className="px-6 py-4 border-b border-secondary/10 bg-primary">
              <DialogTitle className="text-lg font-bold text-white uppercase tracking-tight italic">Sample Documents</DialogTitle>
            </DialogHeader>
            <div className="p-4 bg-gray-50">
              <div className="relative w-full rounded-xl overflow-hidden shadow-xl border-4 border-white">
                <Image
                  src="/documentdemo.jpeg"
                  alt="Sample"
                  width={1200}
                  height={800}
                  className="w-full h-auto"
                  unoptimized
                />
              </div>
            </div>
          </DialogContent>
        </Dialog>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <div className="lg:col-span-2 space-y-6">
          {/* Upload Area - Compact */}
          {!zipFile ? (
            <div
              onDrop={handleDrop}
              onDragOver={handleDragOver}
              onDragLeave={handleDragLeave}
              onClick={() => fileInputRef.current?.click()}
              className={cn(
                "relative group overflow-hidden rounded-2xl border-2 border-dashed transition-all duration-700 cursor-pointer min-h-[200px] flex items-center justify-center",
                isDragging
                  ? "bg-primary/5 border-primary shadow-lg scale-[1.01]"
                  : "bg-gray-50/50 border-secondary/20 hover:bg-white hover:border-primary/40 hover:shadow-xl hover:shadow-primary/5"
              )}
            >
              <input
                ref={fileInputRef}
                type="file"
                accept=".zip,application/zip"
                onChange={handleFileInputChange}
                disabled={disabled}
                className="hidden"
              />
              
              <div className="flex flex-col items-center justify-center p-6 text-center max-w-sm">
                <div className={cn(
                  "h-12 w-12 rounded-xl flex items-center justify-center mb-4 transition-all duration-700 shadow-lg",
                  isDragging 
                    ? "bg-primary text-white rotate-12" 
                    : "bg-white text-secondary border border-secondary/10 group-hover:bg-primary group-hover:text-white"
                )}>
                  <UploadCloud className="h-6 w-6" />
                </div>
                <div>
                  <p className="text-base font-bold text-primary tracking-tight mb-1 uppercase">
                    {isDragging ? 'Drop file now' : 'Click to upload or drag and drop'}
                  </p>
                  <p className="text-[9px] text-muted-foreground font-bold uppercase tracking-widest opacity-60">
                    ZIP file containing all documents
                  </p>
                </div>
              </div>
            </div>
          ) : (
            <div className="p-4 rounded-xl bg-emerald-50/30 border border-emerald-500/20 shadow-md animate-in zoom-in-95 duration-700">
              <div className="flex flex-col sm:flex-row items-center justify-between gap-4">
                <div className="flex items-center gap-4">
                  <div className="h-10 w-10 rounded-lg bg-emerald-500 flex items-center justify-center text-white shadow-md rotate-3 transition-transform hover:rotate-0">
                    <File className="h-5 w-5" />
                  </div>
                  <div>
                    <p className="text-sm font-bold text-primary truncate max-w-[180px] sm:max-w-[300px] tracking-tight uppercase">{zipFile.name}</p>
                    <div className="flex items-center gap-2 mt-0.5">
                       <span className="px-2 py-0.5 rounded-md bg-emerald-500/10 text-[8px] font-bold text-emerald-700 uppercase tracking-widest">
                         {(zipFile.size / (1024 * 1024)).toFixed(2)} MB
                       </span>
                       <span className="text-[8px] font-bold text-emerald-600 uppercase tracking-widest">✓ Ready</span>
                    </div>
                  </div>
                </div>
                <Button
                  type="button"
                  onClick={handleRemoveFile}
                  disabled={disabled}
                  className="h-8 px-4 rounded-lg bg-white border border-emerald-500/20 text-destructive font-bold uppercase tracking-widest shadow-sm hover:bg-destructive hover:text-white transition-all active:scale-95 text-[9px]"
                >
                  <X className="w-3.5 h-3.5 mr-1.5" />
                  Remove
                </Button>
              </div>
            </div>
          )}
        </div>

        {/* Instructions Sidebar - Compact */}
        <div className="space-y-4">
          <div className="p-5 rounded-2xl bg-[#0B1120] text-white space-y-4 shadow-xl relative overflow-hidden group">
            <div className="relative z-10">
              <div className="flex items-center gap-2 mb-3">
                 <div className="h-0.5 w-4 bg-secondary rounded-full" />
                 <h6 className="text-[9px] font-bold text-secondary uppercase tracking-[0.2em]">Important Instructions</h6>
              </div>
              <p className="text-[11px] font-medium text-gray-300 leading-relaxed italic border-l-2 border-secondary/30 pl-3 py-0.5">
                "{baseWarning}"
              </p>
            </div>

            <div className="space-y-3 relative z-10">
              <p className="text-[9px] font-bold text-white/40 uppercase tracking-[0.1em]">Required Documents</p>
              <div className="grid grid-cols-1 gap-2">
                {requiredDocs.map((doc, index) => (
                  <div key={index} className="flex items-center gap-2.5">
                    <div className="h-1 w-1 rounded-full bg-secondary shadow-lg shadow-secondary/50" />
                    <span className="text-[10px] font-bold text-gray-200 uppercase tracking-wide">{doc}</span>
                  </div>
                ))}
              </div>
            </div>

            <div className="pt-4 border-t border-white/5 relative z-10">
              <p className="text-[9px] text-gray-500 font-bold leading-relaxed uppercase tracking-widest text-center">
                Aggregate documents into a single ZIP archive.
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};
