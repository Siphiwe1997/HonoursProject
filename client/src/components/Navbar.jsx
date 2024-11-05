import React from "react";
import { HiMenuAlt4 } from "react-icons/hi";
import { AiOutlineClose } from "react-icons/ai";
import { Link } from "react-router-dom";
import { ConnectButton } from "thirdweb/react"; 
import { client, chain } from "../utils/constants"; 
import logo from "../../images/logo_2.png";

const NavBarItem = ({ title, classprops, link }) => (
  <li className={`mx-4 cursor-pointer ${classprops}`}>
    <Link to={link}>{title}</Link>
  </li>
);

const Navbar = () => {
  const [toggleMenu, setToggleMenu] = React.useState(false);

  return (
    <nav className="w-full flex justify-between items-center p-4">
      <div className="flex-initial justify-center items-center">
        <Link to="/">
          <img src={logo} alt="logo" className="w-32 cursor-pointer" />
        </Link>
      </div>
      
      {/* Toggle Button for Small Screens */}
      <div className="flex md:hidden">
        {!toggleMenu ? (
          <HiMenuAlt4 fontSize={28} className="text-white cursor-pointer" onClick={() => setToggleMenu(true)} />
        ) : (
          <AiOutlineClose fontSize={28} className="text-white cursor-pointer" onClick={() => setToggleMenu(false)} />
        )}
      </div>
      
      {/* Main Menu */}
      <ul className={`text-white md:flex list-none flex-row justify-between items-center flex-initial ${toggleMenu ? 'flex' : 'hidden'} md:flex`}>
        {[
          { name: "Wallets", link: "/wallets" },
          { name: "Exchange", link: "/" },
        ].map((item, index) => (
          <NavBarItem key={item.name + index} title={item.name} link={item.link} />
        ))}
        <li className="mx-4">
          <ConnectButton 
            client={client} 
            chain={chain} 
            connectModal={{ size: "compact" }} 
          />
        </li>
      </ul>
    </nav>
  );
};

export default Navbar;
