import os

def update_file(file_path):
    print(f"Scanning {file_path} for old header artifacts...")
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # Pattern 1: The Big Text
    # doc.setFont("helvetica", "bold");
    # doc.setFontSize(18);
    # doc.setTextColor(30, 41, 59);
    # doc.text("Benazir Bhutto Shaheed Human Resource", 45, 20);
    # doc.text("Research & Development Board", 45, 28);
    
    # We will look for just the text line to be safe
    old_text_sig = 'doc.text("Benazir Bhutto Shaheed Human Resource", 45, 20);'
    
    idx = content.find(old_text_sig)
    if idx != -1:
        print(f"FOUND OLD HEADER at index {idx}!")
        
        # We need to find the START of this block, likely `// 1. HEADER LOGO & BRANDING` before it.
        # Or simply replace from `doc.setFont("helvetica", "bold");` (approx 100 chars back)
        # up to `doc.text("OFFICIAL ACADEMIC TRANSCRIPT", ...);`
        
        # Let's find the start of the function or block.
        # Search backwards for `// 1. HEADER LOGO & BRANDING`
        start_marker = '// 1. HEADER LOGO & BRANDING'
        idx_start = content.rfind(start_marker, 0, idx)
        
        # Search forwards for the end of the header section.
        # usually `// 2. REPORT DETAILS GRID`
        end_marker = '// 2. REPORT DETAILS GRID'
        idx_end = content.find(end_marker, idx)
        
        if idx_start != -1 and idx_end != -1:
            print(f"Replacing block from {idx_start} to {idx_end}")
            
            new_header = """// 1. HEADER LOGO & BRANDING
                // Background (White)
                doc.setFillColor(255, 255, 255);
                doc.rect(0, 0, 210, 50, 'F');

                const logoX = 14; 
                const logoY = 12;
                const logoWidth = 35; 
                const logoHeight = 20;

                // Logo
                if (window.bbsydpLogo) {
                    try { doc.addImage(window.bbsydpLogo, "PNG", logoX, logoY, logoWidth, logoHeight); } catch (e) {}
                } else {
                     try { doc.addImage("assets/bbsydp_logo.png", "PNG", logoX, logoY, logoWidth, logoHeight); } catch(ex){}
                }

                // Org Name Stack (Modern)
                const textX = logoX + logoWidth + 8;
                doc.setFont("helvetica", "bold");
                doc.setTextColor(15, 23, 42); // Slate 900
                doc.setFontSize(12);

                doc.text("Benazir Bhutto Shaheed", textX, 17);
                doc.text("Human Resource Research &", textX, 22);
                doc.text("Development Board", textX, 27);

                // Title: OFFICIAL TRANSCRIPT Badge
                const badgeWidth = 70; 
                const badgeHeight = 14;
                const badgeX = 210 - 20 - badgeWidth; 
                const badgeY = 12;
                
                doc.setFillColor(37, 99, 235); // Blue 600
                doc.roundedRect(badgeX, badgeY, badgeWidth, badgeHeight, 4, 4, 'F');
                
                doc.setTextColor(255, 255, 255);
                doc.setFont("helvetica", "bold");
                doc.setFontSize(10);
                doc.text("OFFICIAL TRANSCRIPT", badgeX + (badgeWidth/2), badgeY + 9, { align: "center" });

                // Divider
                doc.setDrawColor(226, 232, 240);
                doc.setLineWidth(0.5);
                doc.line(0, 50, 210, 50);
                
                """
            content = content[:idx_start] + new_header + content[idx_end:]
            
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(content)
            print("Successfully nuked old header.")
        else:
            print("Could not bracket the old header.")
    else:
        print("Old header signature not found.")
        
    # ALSO: Check if there's a SECOND duplicate.
    if content.count(old_text_sig) > 0:
        print("WARNING: More duplicates might exist!")

update_file(r'c:\Users\Hon3y Chauhan\Desktop\BBSYDP-LMS\index.html')
