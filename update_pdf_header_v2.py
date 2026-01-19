import os

def update_file(file_path):
    print(f"Updating {file_path}...")
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    start_marker = '// --- HEADER ---'
    end_marker = 'doc.text("PERFORMANCE REPORT", pageWidth - margin, 22, { align: "right" });'
    
    # Note: The end_marker might verify against the OLD content if it wasn't strictly replaced or if I'm searching for the *previous* state's signature
    # In the LAST step, I replaced the end marker with: 
    # doc.text(dateStr, rightMargin, 26, { align: "right" });
    # sending "PERFORMANCE REPORT" to line 20 with specific variable `rightMargin`.
    
    # So the *previous* ReplaceFileContent actually *changed* the content.
    # The start_marker should still be there.
    # The end marker of the *block I wrote last time* was:
    # doc.text(dateStr, rightMargin, 26, { align: "right" });
    
    # However, to be safe and robust, let's identify the block by its start and the next known stable point.
    # The header block is followed by `// --- TABLE ---` or similar structure?
    # Let's look at the ViewFile content from earlier (Step 427/464).
    # It was followed by `// --- TABLE ---` or logic for table.
    # Let's try to match from `// --- HEADER ---` down to `doc.setDrawColor(0);` or `doc.setFontSize(12);` which usually starts the body.
    
    # Actually, looking at my previous `update_pdf_header.py` (Step 469/471), I defined `new_header` text.
    # I can just search for that exact text block to replace it, OR search for the generic boundaries again.
    # Since I just wrote the file, I know what it looks like *now*.
    
    # Current Content snippet safely identifiable:
    # doc.line(0, 50, pageWidth, 50);
    # ...
    # doc.text(dateStr, rightMargin, 26, { align: "right" });
    
    # I want to replace everything from `// --- HEADER ---` to `doc.text(dateStr, rightMargin, 26, { align: "right" });`
    
    start_search = '// --- HEADER ---'
    end_search = 'doc.text(dateStr, rightMargin, 26, { align: "right" });'
    
    start_idx = content.find(start_search)
    end_idx = content.find(end_search)
    
    if start_idx == -1 or end_idx == -1:
        print(f"Check failed for {file_path}. Start: {start_idx}, End: {end_idx}. Trying fallback search...")
        # Fallback: maybe the previous tool failed or user reverted? 
        # Or maybe I am searching for the Wrong string (e.g. variable naming).
        # Let's try to find the start and just replace a large chunk until we see something unique to the NEXT section.
        # Next section usually involves `autoTable` or `const columns`.
        # Let's search for `// --- HEADER ---` and `// --- CONTENT ---` or `// --- TABLE ---` if it exists.
        # If not, let's look for `window.generateResult` context.
        return

    end_idx += len(end_search)

    # New Layout with MaxWidth and specific spacing
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
            const textStart = leftMargin + logoWidth + 6; // slightly more padding

            // Logo Image
            if (window.bbsydpLogo) {
                try {
                    doc.addImage(window.bbsydpLogo, "PNG", leftMargin, 12, logoWidth, 26);
                } catch (e) { }
            }

            // --- RIGHT BLOCK (Render first to ensure alignment) ---
            const rightMargin = pageWidth - 14;
            
            doc.setFont("helvetica", "bold");
            doc.setTextColor(30, 41, 59); // Slate 800
            doc.setFontSize(14);
            doc.text("PERFORMANCE REPORT", rightMargin, 20, { align: "right" });

            doc.setFont("helvetica", "normal");
            doc.setTextColor(100, 116, 139); // Slate 500
            doc.setFontSize(9);
            const dateStr = `Generated: ${new Date().toLocaleDateString()}`;
            doc.text(dateStr, rightMargin, 26, { align: "right" });

            // --- LEFT BLOCK ---
            doc.setFont("helvetica", "bold");
            doc.setTextColor(30, 41, 59); // Slate 800
            doc.setFontSize(22);
            doc.text("BBSHRRD LMS", textStart, 20); 

            // Subtitle (Wrapped to avoid overlap)
            doc.setFont("helvetica", "normal");
            doc.setTextColor(71, 85, 105); // Slate 600
            doc.setFontSize(9);
            // Limit width to 85mm to strictly avoid the Right Block (which starts approx at x=150)
            // textStart is ~65. 65+85 = 150. Safe.
            doc.text("Benazir Bhutto Shaheed Human Resource Research & Development Board", textStart, 26, { maxWidth: 85 });

            // Trade (Moved down to 38 to account for subtitle wrapping)
            doc.setFont("helvetica", "bold");
            doc.setTextColor(79, 70, 229); // Indigo 600
            doc.setFontSize(10);
            doc.text("Trade: Web Development With Python", textStart, 38);"""

    new_content = content[:start_idx] + new_header + content[end_idx:]
    
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(new_content)
    print(f"Successfully updated {file_path}")

update_file(r'c:\Users\Hon3y Chauhan\Desktop\BBSYDP-LMS\index.html')
update_file(r'c:\Users\Hon3y Chauhan\Desktop\BBSYDP-LMS\index2.html')
