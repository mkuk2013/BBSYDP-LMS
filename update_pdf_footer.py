import os

def update_file(file_path):
    print(f"Updating Footer in {file_path} ...")
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # Search for common footer text or patterns in both files
    # index.html uses `addFooter` helper distinct from the main flow in some places
    # but `index2.html` might have it inline or in `addFooter`.
    
    # We'll try to match the `addFooter` function body if it exists, or the inline footer calls.
    # Common signature: `doc.text("This report is digitally signed...` or similar.
    # We will simply Replace ANY instance of doc.text(...) related to footer with the new Lines.
    
    # Let's replace the Valid Until / Generated via text blocks first if they exist (Old style)
    # Old Style:
    # doc.text("This document is valid without a physical signature.", 105, pageHeight - 15, { align: "center" });
    # doc.text("Generated via BBSHRRDB LMS v2.0", 105, pageHeight - 10, { align: "center" });
    
    # New Style Request strings
    line1 = "This report is digitally signed and officially verified by Program Instructor."
    line2 = "BBSHRRDB Learning Management System v2.0"
    
    # Strategy: Find the "Valid without..." line and replace the block.
    # Note: Regex might be safer, but let's try direct string find first as we likely have specific text.
    
    # OLD TEXTS TO MATCH (Typical)
    old_line1_variants = [
        'doc.text("This document is valid without a physical signature."',
        'doc.text("This report is digitally signed and officially verified' # In case already partially there
    ]
    
    # We construct the New Block to replace whatever we find.
    # We assume `pageWidth / 2` or `105` is used for centering. prefer `pageWidth / 2` variable if available, else `105` (A4 center).
    # Since we are editing JS, we should stick to using the variable `pageWidth / 2` if we are inside a function that defines it, or `105` if we are sure it's A4.
    # Most reliable: Use `doc.internal.pageSize.width / 2` or just `105` (since A4 is 210).
    
    # Let's look for the block start `// Valid until` or `// Footer`
    
    # Block type 1 (index2.html likely)
    # // Valid until
    # doc.setFontSize(8);
    # doc.setTextColor(100);
    # doc.text("This document is valid without a physical signature.", 105, pageHeight - 15, { align: "center" });
    # doc.text("Generated via BBSHRRDB LMS v2.0", 105, pageHeight - 10, { align: "center" });
    
    replacement_block = f"""// Footer
                doc.setFontSize(8);
                doc.setTextColor(150); // Light Gray
                doc.setFont("helvetica", "normal");
                // Center roughly at 105 (A4/2)
                doc.text("{line1}", 105, pageHeight - 15, {{ align: "center" }});
                doc.text("{line2}", 105, pageHeight - 10, {{ align: "center" }});"""
                
    # We will try to replace the chunk starting from `// Valid until` to the end of that text block.
    
    if '// Valid until' in content:
        start_marker = '// Valid until'
        # Approximate end: 
        # doc.text("...", ..., ..., { align: "center" });
        # doc.text("...", ..., ..., { align: "center" }); <-- End of this
        
        idx_start = content.find(start_marker)
        # Find newline after the second doc.text following this.
        # Quick hack: split by newline, replace lines.
        
        # Better: Replace the specific strings if matched.
        new_content = content.replace(
            'doc.text("This document is valid without a physical signature.", 105, pageHeight - 15, { align: "center" });',
            f'doc.text("{line1}", 105, pageHeight - 15, {{ align: "center" }});'
        )
        new_content = new_content.replace(
            'doc.text("This document is valid without a physical signature.", pageWidth / 2, pageHeight - 15, { align: "center" });',
             f'doc.text("{line1}", pageWidth / 2, pageHeight - 15, {{ align: "center" }});'
        )
        
        # Second line replacement
        # Matches "Generated via..."
        # We need to be careful not to break things.
        # Let's simple Regex Replace the specific lines.
        
        import re
        
        # Replace Line 1
        # Match `doc.text("This document is valid...` OR `doc.text("This report is...`
        # regex for `doc.text("STRING", X, Y, { align: "center" });`
        
        # Patern for Line 1 (approx Y - 15)
        # We'll just append the new footer at the bottom of the PDF generation functions 
        # overwriting the old one if we can identifying the block.
        
        # Simpler: Just string replace the known old strings.
        
        # Set 1: Old "Valid without..."
        new_content = new_content.replace(
            'This document is valid without a physical signature.',
            line1
        )
        
        # Set 2: Old "Generated via..."
        # This might vary (BBSYDP vs BBSHRRD vs BBSHRRDB). 
        # Regex replace `Generated via .* LMS v2.0`
        new_content = re.sub(
            r'Generated via .* LMS v2.0',
            line2,
            new_content
        )
        
        # Set 3: "Official Transcript - ... Page X" (Header/Footer helper)
        # Not requested to change.
        
        # Set 4: "This report is digitally signed..." (If already exists, just update it)
        # The replacement above handles it if the text matches exact user request.
        
        if content != new_content:
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(new_content)
            print("Updated Footer Text.")
        else:
            print("Footer text already matches or not found.")

    else:
        # Fallback: Look for `addFooter` or just replace known text strings
        print("Marker '// Valid until' not found. Trying direct text replacement.")
        
        new_content = content
        
        # Direct Text Replacements
        replacements = [
            ('This document is valid without a physical signature.', line1),
            ('Generated via BBSHRRDB LMS v2.0', line2),
            ('Generated via BBSYDP LMS v2.0', line2),
            ('Generated via BBSHRRD LMS v2.0', line2),
        ]
        
        for old, new in replacements:
            new_content = new_content.replace(old, new)
            
        if content != new_content:
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(new_content)
            print("Updated Footer Text via direct replacement.")
        else:
            print("No text changes made.")

update_file(r'c:\Users\Hon3y Chauhan\Desktop\BBSYDP-LMS\index.html')
update_file(r'c:\Users\Hon3y Chauhan\Desktop\BBSYDP-LMS\index2.html')
