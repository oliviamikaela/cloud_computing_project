import React from "react";
import DropDown from "../helpers/DropDown";

function Navbar({ setStart, setEnd }) {
  return (
    <div className="h-72 w-3/12 bg-gray-100 flex flex-col justify-center items-center space-y-10 py-10 rounded-md shadow-md">
      <div className=" flex justify-center items-center">
        <button class="bg-gray-800 hover:bg-indigo-dark text-gray-100 font-bold py-2 px-4 w-full inline-flex items-center">
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
          <span class="ml-2">Upload your Data</span>
        </button>
        <input
          class="cursor-pointer absolute block opacity-0 pin-r pin-t"
          type="file"
          name="vacancyImageFiles"
          multiple
        />
      </div>

      <div className="flex justify-center items-center">
        <div className="">
          <DropDown />
        </div>
      </div>
      <div className="flex justify-center items-center space-x-5 ">
        <button className="bg-gray-800 hover:bg-gray-900 text-gray-200 font-bold py-2 md:px-4 px-2 rounded text-lg">
          Start
        </button>
        <button className="bg-gray-800 hover:bg-gray-900 text-gray-200 font-bold py-2 md:px-5 px-3 rounded text-lg">
          End
        </button>
      </div>
    </div>
  );
}

export default Navbar;
