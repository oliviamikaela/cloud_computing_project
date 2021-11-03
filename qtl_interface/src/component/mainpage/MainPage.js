import React, { useState, useEffect } from "react";
import DropDown from "../helpers/DropDown";
import axios from "axios";

function MainPage() {
  const [start, setStart] = useState(false);
  const [end, setEnd] = useState(false);
  const [workerNum, setWorkerNum] = useState("sh ./run_terraform.sh");
  const [ipAddress, setIpAddress] = useState(null);
  const [token, setToken] = useState(null);

  useEffect(() => {
    console.log(start, end, workerNum);
    axios
      .post("http://localhost:8080", [start, end, workerNum])
      .then(() => console.log("request sent"))
      .catch((err) => {
        console.error(err);
      });
  }, [start, end]);

  useEffect(() => {
    axios
      .get("http://localhost:8080/ip")
      .then((res) => {
        const ip = `http://${res.data[1]}:60060`;
        const theToken = res.data[0];
        setIpAddress(ip);
        setToken(theToken);
        console.log(res.data);
      })
      .catch((err) => {
        console.error(err);
      });
  }, []);

  useEffect(() => {
    console.log(ipAddress);
  }, [ipAddress]);
  return (
    <div className=" bg-green-400 flex flex-col justify-center items-center space-y-5 px-20 py-10 rounded-lg shadow-xl">
      <div className="flex justify-center items-center font-mono text-lg md:text-2xl font-bold mb-5">
        QTL as a Service
      </div>
      <div className=" flex justify-center items-center">
        <button className="bg-green-700  text-gray-100 font-bold py-2 px-4 w-full inline-flex items-center rounded-lg">
          <svg
            fill="#FFF"
            height="18"
            viewBox="0 0 24 24"
            width="18"
            xmlns="http://www.w3.org/2000/svg"
          >
            <path d="M0 0h24v24H0z" fill="none" />
            <path d="M9 16h6v-6h4l-7-7-7 7h4zm-4 2h14v2H5z" />
          </svg>
          <span className="ml-2">Upload your Data</span>
        </button>
        <input
          className="cursor-pointer absolute block opacity-0 pin-r pin-t"
          type="file"
          name="vacancyImageFiles"
          multiple
        />
      </div>

      <div className="flex justify-center items-center">
        <DropDown setWorkerNum={setWorkerNum} />
      </div>
      <div className="flex justify-center items-center mt-5"></div>
      <div className="flex justify-center items-center space-x-5 ">
        <button
          className="bg-green-700 hover:bg-green-900 text-gray-100 font-bold py-2 md:px-6 px-3 rounded-lg text-lg"
          onClick={() => {
            if (start == false) {
              setEnd(false);
              setStart(true);
            }
          }}
        >
          Start
        </button>
        <button
          className="bg-green-700 hover:bg-green-900 text-gray-100 font-bold py-2 md:px-7 px-4 rounded-lg text-lg"
          onClick={() => {
            if (end == false) {
              setStart(false);
              setEnd(true);
            }
          }}
        >
          End
        </button>
      </div>
      <div className="flex justify-center items-center mt-10"></div>
      <div className="flex justify-center items-center">
        {ipAddress == null ? (
          <button
            disabled
            className="bg-gray-700 bg-opacity-20 text-gray-300 font-bold py-2 md:px-7 px-4 rounded-lg text-lg"
          >
            GO to Jupyter
          </button>
        ) : (
          <div className="flex-col justify-center items-center space-y-10">
            <div className="flex justify-center">
              <button className="bg-gray-700 hover:bg-gray-900 text-gray-100 font-bold py-2 md:px-7 px-4 rounded-lg text-lg">
                <a href={ipAddress} target="_blank">
                  GO to Jupyter
                </a>
              </button>
            </div>
            <div className="flex-col justify-center items-center space-y-2">
              <div className="text-gray-200">
                Use this token to login for Jupyter
              </div>
              <div className="bg-gray-200 px-5 py-2 md:px-7 px-4 rounded-lg">
                {token}
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}

export default MainPage;
