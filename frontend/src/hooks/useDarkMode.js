import { useState, useEffect } from "react";

export default function useDarkMode() {
 const [theme, setTheme] = useState("light");

 const setMode = (mode) => {
  window.localStorage.setItem("theme", mode);
  setTheme(mode);
 };

 const toggleTheme = () => {
  if (theme === "light") {
   setMode("dark");
  } else {
   setMode("light");
  }
 };

 useEffect(() => {
  const localTheme = window.localStorage.getItem("theme");
  localTheme && setTheme(localTheme);
 }, []);

 return [theme, toggleTheme];
}
