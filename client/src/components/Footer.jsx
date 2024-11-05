import React from "react";
import { FaFacebookF, FaTwitter, FaInstagram, FaLinkedinIn } from "react-icons/fa";

const Footer = () => (
  <footer className="w-full flex flex-col items-center p-8 gradient-bg-footer">
    {/* Logo or Branding Section */}
    <div className="flex justify-center items-center mb-6">
      <h1 className="text-white text-3xl font-bold">QuantumSpectra</h1>
    </div>

    {/* Navigation Links */}
    <div className="flex justify-center items-center space-x-6 mb-6">
      <a href="/" className="text-white text-sm hover:underline">
        Market
      </a>
      <a href="/" className="text-white text-sm hover:underline">
        Exchange
      </a>
      <a href="/" className="text-white text-sm hover:underline">
        Tutorials
      </a>
      <a href="/" className="text-white text-sm hover:underline">
        About Us
      </a>
    </div>

    {/* Contact and Tagline */}
    <div className="flex flex-col items-center mb-6">
      <p className="text-white text-center text-sm">
        Join us for the unexpected miracle in the world of blockchain
      </p>
      <p className="text-white text-sm mt-2 font-medium">
        info@qauantumspectra.com
      </p>
    </div>

    {/* Social Media Icons */}
    <div className="flex space-x-4 mb-6">
      <a href="https://facebook.com" target="_blank" rel="noopener noreferrer">
        <FaFacebookF className="text-white text-xl hover:text-gray-400" />
      </a>
      <a href="https://twitter.com" target="_blank" rel="noopener noreferrer">
        <FaTwitter className="text-white text-xl hover:text-gray-400" />
      </a>
      <a href="https://instagram.com" target="_blank" rel="noopener noreferrer">
        <FaInstagram className="text-white text-xl hover:text-gray-400" />
      </a>
      <a href="https://linkedin.com" target="_blank" rel="noopener noreferrer">
        <FaLinkedinIn className="text-white text-xl hover:text-gray-400" />
      </a>
    </div>

    {/* Divider */}
    <div className="w-full h-[0.25px] bg-gray-400 mt-5 sm:w-[90%]" />

    {/* Copyright and Rights */}
    <div className="w-full flex justify-between items-center mt-3 sm:w-[90%]">
      <p className="text-white text-left text-xs">@QuantumSpectra2024</p>
      <p className="text-white text-right text-xs">All rights reserved</p>
    </div>
  </footer>
);

export default Footer;
