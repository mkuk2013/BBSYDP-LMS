import os

def update_file(file_path):
    print(f"Updating {file_path}...")
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # Define the start and end markers for the block we want to replace
    # We want to replace everything from "// --- HEADER ---" 
    # down to the line *before* "// --- TABLE ---" or just match the block structure.
    # Looking at the file content, the header block ends and then we proceed to other stuff.
    # But checking the view_file from earlier, after the header text, we have:
    # doc.text("PERFORMANCE REPORT", ...);
    # And then likely "const columns = ..."?
    # Let's verify what comes after. In step 427, we saw up to line 7000.
    # In step 464, we saw up to 7009.
    # It ends with doc.text(..., { align: "right" });
    
    # I will replace the block starting at `// --- HEADER ---`
    # and ending at `doc.text("PERFORMANCE REPORT", pageWidth - margin, 22, { align: "right" });`
    
    start_marker = '// --- HEADER ---'
    end_marker = 'doc.text("PERFORMANCE REPORT", pageWidth - margin, 22, { align: "right" });'
    
    start_idx = content.find(start_marker)
    end_idx = content.find(end_marker)
    
    if start_idx == -1 or end_idx == -1:
        print(f"Check failed for {file_path}. Start: {start_idx}, End: {end_idx}")
        # Try to debug
        # Maybe exact string for end marker is different? 
        # In step 464: doc.text("PERFORMANCE REPORT", pageWidth - margin, 22, { align: "right" });
        return

    # Adjust end_idx to include the end_marker length
    end_idx += len(end_marker)

    # New Content
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
            const textStart = leftMargin + logoWidth + 5; // ~64

            // Logo Image
            if (window.bbsydpLogo) {
                try {
                    // Adjusted width to 45 for ~1.73 aspect ratio
                    doc.addImage(window.bbsydpLogo, "PNG", leftMargin, 12, logoWidth, 26);
                } catch (e) { }
            }

            // --- LEFT BLOCK ---
            doc.setFont("helvetica", "bold");
            doc.setTextColor(30, 41, 59); // Slate 800
            
            // Title
            doc.setFontSize(20);
            doc.text("BBSHRRD LMS", textStart, 20); 

            // Subtitle
            doc.setFont("helvetica", "normal");
            doc.setTextColor(71, 85, 105); // Slate 600
            doc.setFontSize(9);
            doc.text("Benazir Bhutto Shaheed Human Resource Research & Development Board", textStart, 26);

            // Trade
            doc.setFont("helvetica", "bold");
            doc.setTextColor(79, 70, 229); // Indigo 600
            doc.setFontSize(10);
            doc.text("Trade: Web Development With Python", textStart, 34);

            // --- RIGHT BLOCK ---
            const rightMargin = pageWidth - 14;

            // Report Title
            doc.setTextColor(30, 41, 59); // Slate 800
            doc.setFontSize(14);
            doc.setFont("helvetica", "bold");
            doc.text("PERFORMANCE REPORT", rightMargin, 20, { align: "right" });

            // Generated Date
            doc.setFont("helvetica", "normal");
            doc.setTextColor(100, 116, 139); // Slate 500
            doc.setFontSize(9);
            const dateStr = `Generated: ${new Date().toLocaleDateString()}`;
            doc.text(dateStr, rightMargin, 26, { align: "right" });"""

    new_content = content[:start_idx] + new_header + content[end_idx:]
    
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(new_content)
    print(f"Successfully updated {file_path}")

update_file(r'c:\Users\Hon3y Chauhan\Desktop\BBSYDP-LMS\index.html')
update_file(r'c:\Users\Hon3y Chauhan\Desktop\BBSYDP-LMS\index2.html')
