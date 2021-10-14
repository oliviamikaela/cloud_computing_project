import "./App.css";
import React, { useState, useEffect } from "react";
import Header from "./component/header/Header";
import MainPage from "./component/mainpage/MainPage";
import Navbar from "./component/navbar/Navbar";

function App() {
  const [start, setStart] = useState(false);
  const [end, setEnd] = useState(false);
  return (
    <div className="min-h-screen bg-opacity-30 bg-indigo-100 min-w-screen">
      <div className="flex flex-col space-y-5 ">
        <Header />
        <div className="flex justify-start w-full ">
          <Navbar start={setStart} end={setEnd} />
          <MainPage />
        </div>
      </div>
    </div>
  );
}

export default App;