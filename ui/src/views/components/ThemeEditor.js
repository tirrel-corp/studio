import { useState, useEffect, useRef } from "react";
import { themeConstants } from "../../lib/constants";
import * as valid from "../utils/validators";
import fonts from '../../assets/fonts/google-fonts.json';

export default function ThemeEditor({ prevName, prevColors, onSave }) {

    const initialValues = prevColors
        ? [
            ...Object.entries(prevColors).filter(([k,]) => k !== 'font').map(([k, v]) => ({ ...themeConstants.find((e) => `--${e.name}` === k), ...{ color: v } }))
        ]
        : themeConstants.map((e) => ({ ...e, color: "#fffff" }));
    const validFonts = fonts.items.filter((e) => e?.files?.regular);
    const findFontByName = (fontName) => validFonts.find((e) => e.family === fontName);
    const resolvedFont = validFonts.find((e) => e?.files?.regular === prevColors?.font);
    const inter = fonts.items.find((e) => e?.family === "Inter");
    const [colors, setColors] = useState(initialValues);
    const [name, setName] = useState(prevName || '');
    const [font, setFont] = useState(resolvedFont || inter);
    const preview = useRef(0);

    useEffect(() => {
        applyColors(colors, font, preview)
    }, [colors, font, preview]);

    return <div className="pa2 ba mv3 fieldset">
        <div className='tc mb4'>
            <label htmlFor="style-name">Style name</label>
            <input
                className="ml2"
                name="style-name"
                placeholder="my-style"
                onChange={(e) => setName(e.target.value)}
                value={name} />
        </div>
        <div className='flex justify-between mb4' style={{ gap: '1rem' }}
        >
            <div className="flex flex-column">
                {colors.map((themeVar) => <div key={themeVar.name} className="flex pa2 items-center justify-center">
                    <label className="w-100" htmlFor={themeVar.name}>{themeVar.desc}</label>
                    <input className='ml2 pa0' type="color" onChange={(e) =>
                        setColors(colors.map((color) => {
                            if (color.name !== themeVar.name) return color;
                            return { ...color, color: e.target.value }
                        }))} value={themeVar.color} />
                </div>
                )}
                <div className="flex pa2 items-center justify-center">
                    <label className="w-100" htmlFor="font">Font</label>
                    <select className="ml2 mw5" onChange={(e) => setFont(findFontByName(e.target.value))} value={font?.family}>
                        {validFonts.map((font) => <option key={font.family}>{font.family}</option>)}
                    </select>
                </div>
            </div>
            <iframe
                className="overflow-hidden ba b--moon-gray"
                style={{ "pointer-events": "none",
                    "border-width": "var(--w-3)",
                    "border-radius": "var(--w-2)",
                }}
                onLoad={() => applyColors(colors, font, preview)}
                scrolling="no"
                id="preview" src="/apps/studio/preview.html"
                ref={preview}
                title="preview"
            />
        </div>
        <button type="submit" onClick={(e) => {
            e.preventDefault();
            onSave(name, colors, font)
        }}>Save theme</button>
    </div>
}

const applyColors = (colors, font, preview) => {
    const document = preview?.current?.contentWindow?.document;
    const element = preview?.current?.contentWindow?.document?.documentElement?.style;
    if (element) {
        document.head.querySelector("style")?.remove();
        document.head.insertAdjacentHTML("beforeend", `<style>
        @font-face {
            font-family: 'imported-font';
            src: url('${font.files.regular}');
            }
            body { font-family: 'imported-font' !important; }
            </style>          
        `)
        return colors.map((color) => {
            return element.setProperty(`--${color.name}`, color.color);
        })
    }
}
