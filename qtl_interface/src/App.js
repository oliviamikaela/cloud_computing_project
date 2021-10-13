import "./App.css";
import Header from "./component/header/Header";
import MainPage from "./component/mainpage/MainPage";

function App() {
  return (
    <div className="min-h-screen bg-opacity-30 bg-indigo-50 min-w-screen">
      <Header />
      <MainPage />
    </div>
  );
}

export default App;
