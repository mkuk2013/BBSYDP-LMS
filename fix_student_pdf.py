import os

def update_file(file_path):
    print(f"Updating {file_path} for Student PDF Fix...")
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # We need to replace the Header section inside `window.downloadReport` in index2.html
    # It starts around line 5710 in the previous view.
    # Search for `// 1. HEADER LOGO & BRANDING`
    # End around `// divider` line 5727.
    
    start_sig = '// 1. HEADER LOGO & BRANDING'
    end_sig = '// 2. REPORT DETAILS GRID'
    
    idx_start = content.find(start_sig)
    idx_end = content.find(end_sig)
    
    if idx_start != -1 and idx_end != -1:
        # We will replace the header logic with the "Modern" version
        # but keep "OFFICIAL ACADEMIC TRANSCRIPT" instead of "Performance Report"
        
        new_header = """// 1. HEADER LOGO & BRANDING
                // Background (White)
                doc.setFillColor(255, 255, 255);
                doc.rect(0, 0, 210, 50, 'F');

                const logoX = 14; 
                const logoY = 12;
                const logoWidth = 35; 
                const logoHeight = 20;

                // Use Base64 Logo if available, else fallback
                if (window.bbsydpLogo) {
                    try {
                        doc.addImage(window.bbsydpLogo, "PNG", logoX, logoY, logoWidth, logoHeight);
                    } catch (e) {
                         // Fallback to URL if Base64 fails (though Base64 is preferred)
                         try { doc.addImage("assets/bbsydp_logo.png", "PNG", logoX, logoY, logoWidth, logoHeight); } catch(ex){}
                    }
                } else {
                     try { doc.addImage("assets/bbsydp_logo.png", "PNG", logoX, logoY, logoWidth, logoHeight); } catch(ex){}
                }

                // Org Name Stack (Matched to Admin Report)
                const textX = logoX + logoWidth + 8;
                doc.setFont("helvetica", "bold");
                doc.setTextColor(15, 23, 42); // Slate 900
                doc.setFontSize(12);

                // Vertically centered text stack relative to Logo (Midpoint 22)
                doc.text("Benazir Bhutto Shaheed", textX, 17);
                doc.text("Human Resource Research &", textX, 22);
                doc.text("Development Board", textX, 27);

                // Title: OFFICIAL ACADEMIC TRANSCRIPT (Right Aligned)
                // Use a Pill/Badge style for consistency? Or just clean text.
                // Let's use the Badge style but with different text/color? 
                // User input showed simple text "OFFICIAL ACADEMIC TRANSCRIPT"
                // Let's stick to the Blue Badge style for consistency across the system.
                
                const badgeWidth = 70; // Wider for longer text
                const badgeHeight = 14;
                const badgeX = 210 - 20 - badgeWidth; // pageWidth 210
                const badgeY = 12;
                
                doc.setFillColor(37, 99, 235); // Blue 600
                doc.roundedRect(badgeX, badgeY, badgeWidth, badgeHeight, 4, 4, 'F');
                
                doc.setTextColor(255, 255, 255);
                doc.setFont("helvetica", "bold");
                doc.setFontSize(10); // Slightly smaller to fit
                doc.text("OFFICIAL TRANSCRIPT", badgeX + (badgeWidth/2), badgeY + 9, { align: "center" });

                // Divider line
                doc.setDrawColor(226, 232, 240);
                doc.setLineWidth(0.5);
                doc.line(0, 50, 210, 50);
                
                """
        content = content[:idx_start] + new_header + content[idx_end:]
    else:
        print("Header Block Not Found in index2.html")
        
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)
    print(f"Successfully updated {file_path}")

update_file(r'c:\Users\Hon3y Chauhan\Desktop\BBSYDP-LMS\index2.html')
