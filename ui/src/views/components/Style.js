import { useState } from "react";
import ThemeEditor from "./ThemeEditor";
export default function Style({ name, currentStyle = '', values, addTheme, deleteTheme }) {
    const [showEditor, setShowEditor] = useState(false);
    return <div className="flex flex-column mv2">
        <div className='flex items-center'>
            <input
                className="mr2"
                type="radio"
                id={`style-${name}`}
                name="style"
                value={name}
                defaultChecked={currentStyle === name}
            />
            <label htmlFor={`style-${name}`}>{name}</label>
            <a className="ml2 pointer" onClick={() => setShowEditor(!showEditor)}>Edit</a>
            <a className="ml2 pointer" onClick={() => deleteTheme(name)}>Delete</a>
        </div>
        {showEditor && <ThemeEditor prevName={name} prevColors={values} onSave={(name, colors, font) => {
            setShowEditor(false)
            return addTheme(name, colors, font)
        }} />}
    </div>
}