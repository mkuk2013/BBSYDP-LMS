const url = "https://bbsydp-redundancy-mkuk2013.aws-us-east-2.turso.io/v2/pipeline";
const token = "eyJhbGciOiJFZERTQSIsInR5cCI6IkpXVCJ9.eyJhIjoicnciLCJpYXQiOjE3NzY3MDYwMjYsImlkIjoiMDE5ZGFiZWUtMGIwMS03YTA0LThlMjktOWQ3ZDc5YmQyZWVlIiwicmlkIjoiM2IzZDg5MzYtZjhhYS00MTY5LWIwNTItMTAxMzMzOTZmNWFmIn0.0RwRbDBf4FNWHahXR6VGKRfR-2EraI1MaOYxyS_tpeDyUm6SdfjDYTIYMRyEPQTfzA3NXItRJ4L-rXcPBAZ6AA";

const statements = [ "SELECT 1" ];

async function run() {
    for (const sql of statements) {
        console.log("Executing:", sql);
        try {
            const res = await fetch(url, {
                method: "POST",
                headers: {
                    "Authorization": `Bearer ${token}`,
                    "Content-Type": "application/json"
                },
                body: JSON.stringify({
                    requests: [
                        { type: "execute", stmt: { sql } },
                        { type: "close" }
                    ]
                })
            });
            console.log("Status:", res.status);
            const data = await res.text();
            console.log("Response:", data);
        } catch(e) {
            console.error("Fetch Error:", e);
        }
    }
}
run();
