macro "Prominence_Finder Tool - C000T0f16PT9f16F" {
   getMinAndMax(min, max);
   middle = (max-min)/2;
   getCursorLoc(x0, y0, z, flags); 
   while (flags&16>0) {
     getCursorLoc(x, y, z, flags); 
      p = middle + 2*middle * (x-x0)/getWidth;
      run("Find Maxima...", "prominence=&p output=[Point Selection]");
      run("Point Tool...", "type=Circle color=Orange size=Large counter=0");
      wait(100);
   }
   print("Prominence:",floor(p));
}

