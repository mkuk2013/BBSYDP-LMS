
const fs = require('fs');
const path = require('path');

const filePath = String.raw`c:\Users\Hon3y Chauhan\Desktop\BBSYDP-LMS\index.html`;
const content = fs.readFileSync(filePath, 'utf8');

// Extract the allQ array content
const startMarker = 'const allQ = [';
const endMarker = '];';
const startIndex = content.indexOf(startMarker);

if (startIndex === -1) {
    console.log('allQ not found');
    process.exit(1);
}

const arrayContent = content.substring(startIndex, content.indexOf(endMarker, startIndex) + 1);

// Parse the array (this is a bit hacky since it's inside HTML/JS, but the format looks clean)
// We'll use eval (safe enough here as we are running it locally on our own code)
// but first we need to strip "const allQ = "
const arrayJson = arrayContent.replace('const allQ = ', '');

try {
    const questions = eval(arrayJson);
    console.log(`Total questions found: ${questions.length}`);
    
    const seen = new Set();
    const duplicates = [];
    
    questions.forEach((q, idx) => {
        if (seen.has(q.q)) {
            duplicates.push({ index: idx, question: q.q });
        }
        seen.add(q.q);
    });
    
    if (duplicates.length > 0) {
        console.log('Duplicates found:');
        duplicates.forEach(d => console.log(`Index ${d.index}: ${d.question}`));
    } else {
        console.log('No duplicate questions found.');
    }
    
    // Also check if we have at least 100
    if (questions.length < 100) {
        console.log(`WARNING: Only ${questions.length} questions available. Need 100.`);
    }

} catch (e) {
    console.error('Error parsing questions:', e);
}
