# Simple Thermostat for Clarity CDS

Simple code for virtual thermostat to be integrated with Clarity CDS

## Description

A ruby script for a virtual thermostat that runs with Clarity CDS (without hardware commands), here you can use iso-thermal (fixed) temperature or 
gradient temperature using gradient table

## Getting Started

### Download the script

### Download Clarity CDS (Demo Version)

* Go to DataApex link to register [here](https://www.dataapex.com/product/clarity-demo?language_content_entity=en)

### Installing Clarity CDS

* No further action needed while installing, keep the default settings

### Installing the script

* Open the Clarity demo version
* Click on (Configuration) icon, then press (OK) on pop-up window
![1](https://user-images.githubusercontent.com/25401184/178685655-fe603d0f-bad5-4717-a142-2a81399523aa.jpg)

* Click (Add) button to add the script), from the opened window, choose (UNI Ruby) under (Auxiliary)
![2](https://user-images.githubusercontent.com/25401184/178685789-5d7ce540-6b5f-4cb6-9cb4-81fd6c22fcff.jpg)

* Load the script, change the thermostat name if you want, then press (OK)
![3](https://user-images.githubusercontent.com/25401184/178685977-80230158-cabf-47a0-9040-c14874c6706b.jpg)

* Load a script for a detector (ex: DetectorExample.rb) found in Clarity_Demo/Bin/UTILS/Uni_Drivers/EXAMPLES
* Choose each module, press (Add selected sub-device) to add them to the device used (GC, HPLC,.....)
![4](https://user-images.githubusercontent.com/25401184/178686101-857f643d-d561-4fb5-ae12-cd8cd628c529.jpg)

* Press (OK) to close

### Using the virtual thermostat
* Open (My GC+AS), press (OK) to pop-up window
* Open (Method setup) button, go to (Thermostat) tab, set the (Initial temperature) to range from (20 to 99.9 0C)
* Set (Allowed temperature difference) from 0.1 to 5.0, this makes the software ready for acquisition once the difference between set and current temperature is in this range
* Set (Equilibration time) to time in minutes from 0 to 5.0, when equilibration is ok, the software will be ready after this time
* You can use temperature gradient, by going to (Temperature gradient) in (Thermostat) tab, enter the (Time) and (Temperature)
* Go to (Advanced) tab, check on (Store) for (Temperature Thermostat 1) in the (Auxiliary Signal) table
* Save the method, click on (Send Method) to update the data entered
* Go to Monitor by pressing (Monitor) button, check the set temperature you entered before, and increasing/decreasing temperature
* Click on (Data Acquisition) button to open the signal window, see the detector and thermostat signals (Note: Sometimes the thermostat doesn't show up, click on (Common for all signals) to refresh the window)
* To run the gradient table, wait until the status is ready, press (Run), check the (Set) temperature in (Monitor) window which changes with time



## Version History

* 0.1
    * Initial Release
