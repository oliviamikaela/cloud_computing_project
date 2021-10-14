import { Menu, Transition } from "@headlessui/react";
import { Fragment, useEffect, useState, useRef } from "react";
import { ChevronDownIcon } from "@heroicons/react/solid";

var head = "Number of workers";
var options = [1, 2, 3, 4, 5, 6];
function DropDown() {
  const [headValue, setHeadValue] = useState(head);

  useEffect(() => {
    setHeadValue(head);
  }, [options]);
  //const [opt2, setOpt2] = useState([1,2,3,4,56,7,3,23,34,4546,243,23,12,12,12,2,455,46,345,234,12,221])
  return (
    <div className=" top-16">
      <Menu as="div" className="relative inline-block w-full text-left ">
        <div>
          <div
            className={`${
              headValue !== head ? "text-gray-100 " : "text-gray-900"
            } block text-xs leading-2 font-light`}
          >
            {head}
          </div>
          <Menu.Button
            className={`${
              headValue !== head
                ? "bg-gray-100 text-gray-600 hover:bg-gray-200"
                : "text-gray-600 bg-gray-100  hover:bg-opacity-70"
            } inline-flex justify-center w-full px-4 py-2 text-sm font-medium  rounded-md  focus:outline-none focus-visible:ring-2 focus-visible:ring-white focus-visible:ring-opacity-75`}
          >
            {headValue}
            <ChevronDownIcon
              className="w-5 h-5 ml-2 -mr-1 text-violet-200 hover:text-violet-100"
              aria-hidden="true"
            />
          </Menu.Button>
        </div>
        <Transition
          as={Fragment}
          enter="transition ease-out duration-100"
          enterFrom="transform opacity-0 scale-95"
          enterTo="transform opacity-100 scale-100"
          leave="transition ease-in duration-75"
          leaveFrom="transform opacity-100 scale-100"
          leaveTo="transform opacity-0 scale-95"
        >
          <Menu.Items className="absolute z-10 w-40 mt-2 overflow-y-auto origin-top-right bg-white divide-y divide-gray-100 rounded-md shadow-lg -left-3 max-h-52 ring-1 ring-black ring-opacity-5 focus:outline-none">
            <div className="px-1 py-1 ">
              {options &&
                options.map((option) => (
                  <Menu.Item key={option}>
                    {({ active }) => (
                      <button
                        className={`${
                          active ||
                          headValue === option ||
                          headValue === "Multi"
                            ? "bg-indigo-500 text-white"
                            : "text-gray-900"
                        }  group flex rounded-md items-center w-full px-2 py-2 text-sm`}
                        onClick={() => {
                          setHeadValue(option);
                        }}
                      >
                        {option}
                      </button>
                    )}
                  </Menu.Item>
                ))}
            </div>
          </Menu.Items>
        </Transition>
      </Menu>
    </div>
  );
}
export default DropDown;
