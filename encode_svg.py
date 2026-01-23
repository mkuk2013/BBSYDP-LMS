
import base64

svg = """<svg width="140" height="140" viewBox="0 0 200 200" xmlns="http://www.w3.org/2000/svg"><defs><path id="curveTop" d="M 40,100 A 60,60 0 0,1 160,100" /><path id="curveBottom" d="M 160,100 A 60,60 0 0,1 40,100" /></defs><circle cx="100" cy="100" r="90" fill="none" stroke="#4f46e5" stroke-width="4" stroke-dasharray="10,2" /><circle cx="100" cy="100" r="82" fill="none" stroke="#4f46e5" stroke-width="1" /><text font-family="sans-serif" font-weight="bold" font-size="20" fill="#4f46e5" letter-spacing="3"><textPath href="#curveTop" startOffset="50%" text-anchor="middle" dominant-baseline="text-after-edge">VERIFIED</textPath></text><text font-family="sans-serif" font-weight="bold" font-size="20" fill="#4f46e5" letter-spacing="3"><textPath href="#curveBottom" startOffset="50%" text-anchor="middle" dominant-baseline="text-before-edge">VERIFIED</textPath></text><rect x="15" y="70" width="170" height="60" rx="30" ry="30" fill="white" stroke="#4f46e5" stroke-width="3" /><rect x="22" y="76" width="156" height="48" rx="24" ry="24" fill="none" stroke="#4f46e5" stroke-width="1" stroke-dasharray="3,3" /><text x="100" y="112" font-family="sans-serif" font-weight="900" font-size="34" fill="#4f46e5" text-anchor="middle">VERIFIED</text></svg>"""

encoded = base64.b64encode(svg.encode('utf-8')).decode('utf-8')
print(f"data:image/svg+xml;base64,{encoded}")
