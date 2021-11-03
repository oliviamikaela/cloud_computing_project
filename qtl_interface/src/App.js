import "./App.css";
import React, { useState, useEffect } from "react";
import MainPage from "./component/mainpage/MainPage";

function App() {
  const [start, setStart] = useState(false);
  const [end, setEnd] = useState(false);
  return (
    <div className="h-screen bg-gray-400 w-screen">
      <div className="flex justify-center items-center w-full h-full ">
        <MainPage start={setStart} end={setEnd} />
      </div>
    </div>
  );
}

export default App;
