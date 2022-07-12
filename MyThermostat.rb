include UNI

#########################################################################
# User written helper global variables.
#########################################################################
# Timer period [ms]
$timerPeriod = 400


#########################################################################
# User written helper function.
#
# Returns true if the given character is a number character.
#########################################################################
def isNumber(ch)
	if (ch >= ?0.ord && ch <= ?9.ord)
		return true
	end
	return false
end



#########################################################################
# Sub-device class expected by framework.
#
# Sub-device represents functional part of the chromatography hardware.
# Thermostat implementation.
#########################################################################
class Thermostat < ThermostatSubDeviceWrapper
	# Constructor. Call base and do nothing. Make your initialization in the Init function instead.
	def initialize
		super
	end
	
	#########################################################################
	# Method expected by framework.
	#
	# Initialize thermostat sub-device. 
	# Set sub-device name, specify method items, specify monitor items, ...
	# Returns nothing.
	#########################################################################	
	def Init
	end
	
end # class Thermostat



#########################################################################
# Device class expected by framework.
#
# Basic class for access to the chromatography hardware.
# Maintains a set of sub-devices.
# Device represents whole box while sub-device represents particular 
# functional part of chromatography hardware.
# The class name has to be set to "Device" because the device instance
# is created from the C++ code and the "Device" name is expected.
#########################################################################
class Device < DeviceWrapper
	# Constructor. Call base and do nothing. Make your initialization in the Init function instead.
	def initialize
		super
	end
	
	#########################################################################
	# Method expected by framework.
	#
	# Initialize configuration data object of the device and nothing else
	# (set device name, add all sub-devices, setup configuration, set pipe
	# configurations for communication, #  ...).
	# Returns nothing.
	#########################################################################	
	def InitConfiguration
     	# Setup configuration.
    	Configuration().AddString("ThermName", "Thermostat name", "Thermostat 1", "VerifyThermostatName")
	end
	
	#########################################################################
	# Method expected by framework.
	#
	# Initialize device. Configuration object is already initialized and filled with previously stored values.
	# (set device name, add all sub-devices, setup configuration, set pipe
	# configurations for communication, #  ...).
	# Returns nothing.
	#########################################################################	
	def Init
		@timeEq=0.0
		@flagEq=true
		
		@aryTemp=nil
		@aryTime=nil
		
		Method().AddDouble("InitTemp", "Initial temperature",ConvertTemperature(45.0,ETU_C,ETU_K), 1, EMeaningTemperature, "VerifyTemperature",false)
		Method().AddDouble("TempTolerance", "Allowed temperature tolerance",0.5, 1, EMeaningTemperatureDifference, "VerifyTempTolerance",false)
		Method().AddDouble("EqTime", "Equilibration time[min]",0.0, 1, EMeaningUnknown, "VerifyEqTime",false)
		
		Method().AddTable("TemperatureGradient", "Temperature Gradient")
	    Method().AddTableColumnDouble("TemperatureGradient", "Time", "Time[min]", 1, EMeaningUnknown, "VerifyTempGradientTime")
	    Method().AddTableColumnDouble("TemperatureGradient", "Temp", "Temperature", 1, EMeaningTemperature, "VerifyTempGradientTemperature") 
		
		Monitor().AddDouble("SetTemp", "Set temperature",ConvertTemperature(30.0,ETU_C,ETU_K),1, EMeaningTemperature, "", true)
		Monitor().AddDouble("CurrTemp", "Current temperature",ConvertTemperature(30.0,ETU_C,ETU_K),1, EMeaningTemperature, "", true)
		
		AuxSignal().AddSignal("Temperature", "Temperature", EMeaningTemperature)
		
		SetName("My lco 102")
		@m_Thermostat=Thermostat.new
		AddSubDevice(@m_Thermostat)
		@m_Thermostat.SetName(Configuration().GetString("ThermName"))
		
		SetHideLoadMethod(true)
		SetTimerPeriod($timerPeriod)
	end
 	
	#########################################################################
	# Method expected by framework.
	#
	# Sets communication parameters.
	# Returns nothing.
	#########################################################################	
	def InitCommunication()
		Communication().SetPipeConfigCount(1)
		Communication().GetPipeConfig(0).SetType(EPT_SERIAL)
		Communication().GetPipeConfig(0).SetBaudRate(2400)
		Communication().GetPipeConfig(0).SetParity(NOPARITY)
		Communication().GetPipeConfig(0).SetDataBits(DATABITS_8)
		Communication().GetPipeConfig(0).SetStopBits(ONESTOPBIT)
	end
	
	#########################################################################
	# Method expected by framework
	#
	# Here you should check leading and ending sequence of characters, 
	# check sum, etc. If any error occurred, use ReportError function.
	#	dataArraySent - sent buffer (can be nil, so it has to be checked 
	#						before use if it isn't nil), array of bytes 
	#						(values are in the range <0, 255>).
	#	dataArrayReceived - received buffer, array of bytes 
	#						(values are in the range <0, 255>).
	# Returns true if frame is found otherwise false.		
	#########################################################################	
	def FindFrame(dataArraySent, dataArrayReceived)
		return true
	end
	
	#########################################################################
	# Method expected by framework
	#
	# Return true if received frame (dataArrayReceived) is answer to command
	# sent previously in dataArraySent.
	#	dataArraySent - sent buffer, array of bytes 
	#						(values are in the range <0, 255>).
	#	dataArrayReceived - received buffer, array of bytes 
	#						(values are in the range <0, 255>).
	# Return true if in the received buffer is answer to the command 
	#   from the sent buffer. 
	# Found frames, for which IsItAnswer returns false are processed 
	#  in ParseReceivedFrame
	#########################################################################		
	def IsItAnswer(dataArraySent, dataArrayReceived)
		return true
	end
	
	#########################################################################
	# Method expected by framework
	#
	# Returns serial number string from HW (to comply with CFR21) when 
	# succeessful otherwise false or nil. If not supported return false or nil.
	#########################################################################	
	def CmdGetSN  	
		return false
	end
	
	#########################################################################
	# Method expected by framework.
	#
	# gets called when instrument opens
	# Returns true when successful otherwise false.
	#########################################################################
	def CmdOpenInstrument
		# Nothing to send.
		
		return true
	end
	
	#########################################################################
	# Method expected by framework.
	#
	# gets called when sequence starts
	# Returns true when successful otherwise false.
	#########################################################################
	def CmdStartSequence
		# Nothing to send.
		return true
	end
	
	#########################################################################
	# Method expected by framework.
	#
	# gets called when sequence resumes
	# Returns true when successful otherwise false.
	#########################################################################
	def CmdResumeSequence
		# Nothing to send.
		return true
	end
	
	#########################################################################
	# Method expected by framework.
	#
	# gets called when run starts
	# Returns true when successful otherwise false.
	#########################################################################
	def CmdStartRun
		# Nothing to send.
		return true
	end
	
	#########################################################################
	# Method expected by framework.
	#
	# gets called when injection performed
	# Returns true when successful otherwise false.
	#########################################################################
	def CmdPerformInjection
		# Nothing to send.
		return true
	end
	
	#########################################################################
	# Method expected by framework.
	#
	# gets called when injection bypassed
	# Returns true when successful otherwise false.
	#########################################################################
	def CmdByPassInjection
		# Nothing to send.
		return true
	end
	
	#########################################################################
	# Method expected by framework.
	#
	# Starts method in HW.
	# Returns true when successful otherwise false.
	#########################################################################
	def CmdStartAcquisition
		if(Method().GetTableRowCount("TemperatureGradient")>0)
			@aryTemp=Array.new(Method().GetTableColumnValues("TemperatureGradient","Temp"))
			@aryTime=Array.new(Method().GetTableColumnValues("TemperatureGradient","Time"))
			Trace(@aryTemp.join(","))
			Trace(@aryTime.join(","))
		end
		Monitor().SetRunning(true)
		Monitor().Synchronize()
		return true
	end
	
	#########################################################################
	# Method expected by framework.
	#
	# gets called when acquisition restarts
	# Returns true when successful otherwise false.
	#########################################################################
	def CmdRestartAcquisition
		# Nothing to send.
		return true
	end	

	#########################################################################
	# Method expected by framework.
	#
	# Stops running method in hardware. 
	# Returns true when successful otherwise false.	
	#########################################################################
	def CmdStopAcquisition
		@aryTemp=nil
		@aryTime=nil
		Monitor().SetDouble("SetTemp",Method().GetDouble("InitTemp"))
		Monitor().SetRunning(false)
		Monitor().Synchronize()
		return true
	end	
	
	#########################################################################
	# Method expected by framework.
	#
	# Aborts running method or current operation. Sets initial state.
	# Returns true when successful otherwise false.	
	#########################################################################
	def CmdAbortRunError
		return CmdStopAcquisition()
	end
	
	#########################################################################
	# Method expected by framework.
	#
	# Aborts running method or current operation (request from user). Sets initial state.
	# Returns true when successful otherwise false.
	#########################################################################
	def CmdAbortRunUser
		return CmdStopAcquisition()
	end
	
	#########################################################################
	# Method expected by framework.
	#
	# Aborts running method or current operation (shutdown). Sets initial state.
	# Returns true when successful otherwise false.	
	#########################################################################
	def CmdShutDown
		CmdAbortRunError()
		return true
	end
	
	#########################################################################
	# Method expected by framework.
	#
	# gets called when run stops
	# Returns true when successful otherwise false.
	#########################################################################
	def CmdStopRun
		# Nothing to send.
		return true
	end
	
	#########################################################################
	# Method expected by framework.
	#
	# gets called when sequence stops
	# Returns true when successful otherwise false.
	#########################################################################
	def CmdStopSequence
		# Nothing to send.
		return true
	end
	
	#########################################################################
	# Method expected by framework.
	#
	# gets called when closing instrument
	# Returns true when successful otherwise false.
	#########################################################################
	def CmdCloseInstrument
		# Nothing to send.
		return true
	end	

	#########################################################################
	# Method expected by framework.
	#
	# Tests whether hardware device is present on the other end of the communication line.
	# Send some simple command with fast response and check, whether it has made it
	# through pipe and back successfully.
	# Returns true when successful otherwise false.
	#########################################################################
	def CmdTestConnect
		return true
	end
	
		
	#########################################################################
	# Method expected by framework.
	#
	# Send method to hardware.
	# Returns true when successful otherwise false.	
	#########################################################################
	def CmdSendMethod()
		Monitor().SetReady(false)
		Monitor().SetDouble("SetTemp",Method().GetDouble("InitTemp"))
		Monitor().Synchronize()
		return true
	
	end
	
	#########################################################################
	# Method expected by framework.
	#
	# Loads method from hardware.
	# Returns true when successful otherwise false.	
	#########################################################################
	def CmdLoadMethod(method)
		return true		
	end
		
	#########################################################################
	# Method expected by framework.
	#
	# Duration of thermostat method.
	# Returns complete (from start of acquisition) length (in minutes) 
	# 	of the current method in sub-device (can use GetRunLengthTime()).
	# Returns METHOD_FINISHED when hardware instrument is not to be waited for or 
	# 	method is not implemented.
	# Returns METHOD_IN_PROCESS when hardware instrument currently processes 
	# 	the method and sub-device cannot tell how long it will take.
	#########################################################################
	def GetMethodLength
		return METHOD_FINISHED
	end	
	
	#########################################################################
	# Method expected by framework.
	#
	# Periodically called function which should update state 
	# of the sub-device and monitor.
	# Returns true when successful otherwise false.	
	#########################################################################
	def CmdTimer
		curr_val=Monitor().GetDouble("CurrTemp")
		set_val=Monitor().GetDouble("SetTemp")
		if(Monitor().IsRunning()==true)
			if(Method().GetTableRowCount("TemperatureGradient")>0)
				SetTemperatureFromGradientTable()
				#return true
			end
		end

		if((curr_val-set_val).abs>Method().GetDouble("TempTolerance"))
			@flagEq=true
			@timeEq=0.0
			curr_val<set_val ? curr_val+=rand(0.2..0.5) : curr_val-=rand(0.2..0.5)
			Monitor().SetDouble("CurrTemp",curr_val)
			Monitor().SetReady(false)
		else
			if(@flagEq==true)
				@timeEq=Process.clock_gettime(Process::CLOCK_MONOTONIC)
				@flagEq=false
			end
			timeNow=Process.clock_gettime(Process::CLOCK_MONOTONIC)
			if(timeNow-@timeEq)>=Method().GetDouble("EqTime")*60
				Monitor().SetReady(true)
			end
		end
		
		Monitor().Synchronize()
		
		
		AuxSignal().WriteSignal("Temperature",curr_val)
		return true
		
	end
	
	
	#########################################################################
	# Method expected by framework
	#
	# gets called when user presses autodetect button in configuration dialog box
	# return true or  false
	#########################################################################
	def CmdAutoDetect
		return CmdTestConnect()
	end
	
	#########################################################################
	# Method expected by framework
	#
	# Processes unrequested data sent by hardware. 
	#	dataArrayReceived - received buffer, array of bytes 
	#						(values are in the range <0, 255>).
	# Returns true if frame was processed otherwise false.
	# The frame found by FindFrame can be processed here if 
	#  IsItAnswer returns false for it.
	#########################################################################
	def ParseReceivedFrame(dataArrayReceived)
		# Passes received frame to appropriate sub-device's ParseReceivedFrame function.
	end
	
		#########################################################################
	# Required by Framework
	#
	# Validates whole method. Use method parameter and NOT object returned by Method(). 
	# There is no need to validate again attributes validated somewhere else.
	# Validation function returns true when validation is successful otherwise
	# it returns message which will be shown in the Message box.	
	#########################################################################
	def CheckMethod(situation,method)
		return true
	end
	
	#########################################################################
	# Required by Framework
	#
	# Gets called when chromatogram is acquired, chromatogram might not exist at the time.
	#########################################################################
	def NotifyChromatogramFileName(chromatogramFileName)
	end
	
	def SetTemperatureFromGradientTable
		if(Method().GetTableRowCount("TemperatureGradient")==0)
			return true
		end
		
		if(@aryTime.length()>0 && GetAcquisitionTime()>=@aryTime[0])
			Trace("Time exceed the first array index value")
			Monitor().SetDouble("SetTemp",@aryTemp[0])
			@aryTime.delete_at(0)
			@aryTemp.delete_at(0)
			Trace("Temp gradient now: "+@aryTime.join(",")+" "+@aryTemp.join(","))		
		end
		Monitor().Synchronize()
		return true
	end
	
	def VerifyTemperature(uiitemcollection,value)
		if (value < ConvertTemperature(20.0,ETU_C,ETU_K) || value > ConvertTemperature(99.9,ETU_C,ETU_K))
			tempMin = ConvertTemperature(20.0, ETU_C, GetTemperatureUIUnits())
			tempMax = ConvertTemperature(99.9, ETU_C, GetTemperatureUIUnits())
			return "Value must be between "+tempMin.to_s+" and "+tempMax.to_s
		end
		return true
	end
	
	def VerifyTempTolerance(uiitemcollection,value)
		if (value < 0.1 || value > 5.0)
			tolMin = ConvertTemperature(0.1, ETU_C, GetTemperatureUIUnits()) - ConvertTemperature(0.0, ETU_C, GetTemperatureUIUnits())
			tolMax = ConvertTemperature(5.0, ETU_C, GetTemperatureUIUnits()) - ConvertTemperature(0.0, ETU_C, GetTemperatureUIUnits())
			return "Value must be between "+tolMin.to_s+" and "+tolMax.to_s
		end
		return true
	end
	
	def VerifyEqTime(uiitemcollection,value)
		if(value < 0.0 || value > 5.0)
			return "Value must be between 0.0 and 5.0"
		end
		return true
	end
	def VerifyTempGradientTime(uiitemcollection,row,value)
		if (row > 100)
			return "Too many items"
		end
		
		if (value > 1000 || value < 0)
			return "Value must be in range 0 to 1000"
		end
		
		aryColTime = Array.new(uiitemcollection.GetTableColumnValues("TemperatureGradient", "Time"))
		if(row>0 && value<=aryColTime[row-1]) #if row is not the first AND value <= previous value
			return "Value must be bigger than previous row value (i.e: must be bigger than "+aryColTime[row-1].to_s+")"
		end
		
		if(row<(aryColTime.length()-1) && value>=aryColTime[row+1]) #if row is not the last AND value entered >= the next value
			return "Value must be smaller than next row value (i.e: must be smaller than "+aryColTime[row+1].to_s+")"
		end
		return true
	end
	
	def VerifyTempGradientTemperature(uiitemcollection,row,value)
		if (row > 100)
			return "Too many items"
		end
		
		if (value < ConvertTemperature(20.0,ETU_C,ETU_K) || value > ConvertTemperature(99.9,ETU_C,ETU_K))
			tempMin = ConvertTemperature(20.0, ETU_C, GetTemperatureUIUnits())
			tempMax = ConvertTemperature(99.9, ETU_C, GetTemperatureUIUnits())
			return "Value must be between "+tempMin.to_s+" and "+tempMax.to_s
		end
		return true
	end
end

def VerifyThermostatName(uiitemcollection,value)
	if(value.length>32)
		return "Name you entered is too long"
	end
end