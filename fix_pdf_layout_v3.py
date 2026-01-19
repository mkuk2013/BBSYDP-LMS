import os

def update_file(file_path):
    print(f"Updating {file_path}...")
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # Identify the block to replace.
    # It starts at `// --- HEADER ---`
    # It ends at `// --- DATA PROCESSING & DEDUPLICATION ---`
    # Or more specifically, I need to remove the STRAY line:
    # doc.text(`Generated: ${new Date().toLocaleDateString()}`, pageWidth - margin, 29, { align: "right" });
    
    start_marker = '// --- HEADER ---'
    # The next Section starts with `// --- DATA PROCESSING & DEDUPLICATION ---` or just `// --- DATA PROCESSING`
    end_marker = '// --- DATA PROCESSING & DEDUPLICATION ---'
    
    start_idx = content.find(start_marker)
    end_idx = content.find(end_marker)
    
    if start_idx == -1 or end_idx == -1:
        print(f"Check failed for {file_path}. Start: {start_idx}, End: {end_idx}")
        return

    # New Clean Header Content
    new_header = """// --- HEADER ---
            // Background (White)
            doc.setFillColor(255, 255, 255);
            doc.rect(0, 0, pageWidth, 50, 'F');
            
            // Bottom Border for Header
            doc.setDrawColor(226, 232, 240); // Slate 200
            doc.setLineWidth(0.5);
            doc.line(0, 50, pageWidth, 50);

            const leftMargin = 14;
            const logoWidth = 45;
            const textStart = leftMargin + logoWidth + 8; // More padding between logo and text

            // Logo Image
            if (window.bbsydpLogo) {
                try {
                    doc.addImage(window.bbsydpLogo, "PNG", leftMargin, 12, logoWidth, 26);
                } catch (e) { }
            }

            // --- RIGHT BLOCK ---
            const rightMargin = pageWidth - 14;
            
            doc.setFont("helvetica", "bold");
            doc.setTextColor(30, 41, 59); // Slate 800
            doc.setFontSize(14);
            doc.text("PERFORMANCE REPORT", rightMargin, 18, { align: "right" });

            doc.setFont("helvetica", "normal");
            doc.setTextColor(100, 116, 139); // Slate 500
            doc.setFontSize(9);
            const dateStr = `Generated: ${new Date().toLocaleDateString()}`;
            doc.text(dateStr, rightMargin, 24, { align: "right" });

            // --- LEFT BLOCK ---
            doc.setFont("helvetica", "bold");
            doc.setTextColor(30, 41, 59); // Slate 800
            doc.setFontSize(22);
            doc.text("BBSHRRD LMS", textStart, 18); 

            // Subtitle (Wrapped)
            doc.setFont("helvetica", "normal");
            doc.setTextColor(71, 85, 105); // Slate 600
            doc.setFontSize(9);
            // Allow wrapping with maxWidth. Text will flow to next lines if needed.
            doc.text("Benazir Bhutto Shaheed Human Resource Research & Development Board", textStart, 24, { maxWidth: 90 });

            // Trade (Moved down safely to y=40 to clear wrapped subtitle)
            doc.setFont("helvetica", "bold");
            doc.setTextColor(79, 70, 229); // Indigo 600
            doc.setFontSize(10);
            doc.text("Trade: Web Development With Python", textStart, 40);

            // Spacer for clean separation before data logic
            
            
            """

    new_content = content[:start_idx] + new_header + content[end_idx:]
    
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(new_content)
    print(f"Successfully updated {file_path}")

update_file(r'c:\Users\Hon3y Chauhan\Desktop\BBSYDP-LMS\index.html')
update_file(r'c:\Users\Hon3y Chauhan\Desktop\BBSYDP-LMS\index2.html')
