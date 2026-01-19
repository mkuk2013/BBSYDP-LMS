import os

def update_file(file_path):
    print(f"Updating {file_path} for Vertical Alignment...")
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # --- REPLACE HEADER BLOCK FOR ALIGNMENT ---
    # Start: `// --- LOGO & ORG NAME (Left) ---`
    # End: `doc.text("Development Board", textX, 26);` or similar from last step.
    # Actually, the last step replaced a chunk ending with `// Tagline "Strengthening the Nation" REMOVED as requested`
    
    # Let's search for the block `// --- LOGO & ORG NAME (Left) ---` to `// --- REPORT BADGE (Right) ---`
    
    start_h = '// --- LOGO & ORG NAME (Left) ---'
    end_h = '// --- REPORT BADGE (Right) ---'
    
    idx_start = content.find(start_h)
    idx_end = content.find(end_h)
    
    if idx_start != -1 and idx_end != -1:
        # We need to shift text down to 17, 22, 27 to center with Logo (12-32, mid 22).
        
        new_header_block = """// --- LOGO & ORG NAME (Left) ---
            const logoX = 14;
            // Logo: 35x20
            const logoWidth = 35;
            const logoHeight = 20;
            const logoY = 12; // Top at 12, Bottom at 32. Midpoint = 22.
            
            if (window.bbsydpLogo) {
                try {
                   doc.addImage(window.bbsydpLogo, "PNG", logoX, logoY, logoWidth, logoHeight); 
                } catch (e) {}
            }
            
            // Org Name Stack
            // Position text closer to the smaller logo
            const textX = logoX + logoWidth + 8; 
            
            doc.setFont("helvetica", "bold");
            doc.setTextColor(15, 23, 42); // Slate 900
            doc.setFontSize(12);
            
            // Vertically centered text stack relative to Logo
            // Logo Midpoint is 22.
            // Text Lines: 17, 22, 27. Midpoint is 22. Perfect Center.
            
            doc.text("Benazir Bhutto Shaheed", textX, 17);
            doc.text("Human Resource Research &", textX, 22);
            doc.text("Development Board", textX, 27);
            
            // Tagline Removed
            
            """
        content = content[:idx_start] + new_header_block + content[idx_end:]
    else:
        print("Header Block Not Found")

    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)
    print(f"Successfully updated {file_path}")

update_file(r'c:\Users\Hon3y Chauhan\Desktop\BBSYDP-LMS\index.html')
update_file(r'c:\Users\Hon3y Chauhan\Desktop\BBSYDP-LMS\index2.html')
