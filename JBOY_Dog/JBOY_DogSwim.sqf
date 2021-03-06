//////////////////////////////////////////////////////////
// JBOY_DogSwim.sqf 
// By: johnnyboy
// dmy = [dog1] execvm "JBOY_Dog\JBOY_DogSwim.sqf";
//////////////////////////////////////////////////////////
_dog     = _this select 0;
_moveToPos = _this select 1;

_speed =  1.1;
_xx = 0;
_sleepTime = .01;
// **************************************************************************
// create physics object to attach dog to while swimming
// **************************************************************************
// for some crazy reason a fish agent moves to fast, and a can object sinks too fast, so using a diver who is nuetrally buoyant. 
_swimmerObj = createAgent ["B_diver_exp_F", [50,5,5], [], 0, "NONE"]; // B_diver_exp_F // Snake_random_F //Kestrel_random_F
//_swimmerObj = createAgent ["Kestrel_random_F", [50,5,5], [], 0, "NONE"]; // B_diver_exp_F // Snake_random_F //Kestrel_random_F
//_swimmerObj ="Kestrel_random_F" createVehicle [0,0,1];   // you can't attach a dog to bird.  fug!
_swimmerObj setbehaviour "CARELESS";
JBOY_swimmer= _swimmerObj;
_swimmerObj setcombatmode "BLUE";
_swimmerObj allowdamage false;
_swimmerObj setcaptive true;
_swimmerObj disableAI "FSM";
_swimmerObj setmass .000001;
_swimmerObj disableAI "ANIM";
removeAllWeapons _swimmerObj;

_swimmerObj hideObjectGlobal true;
_dog disableCollisionWith _swimmerObj;
//_swimmerObj setDir getDir _targetObj;
_pos = getpos _dog;
_dir = getdir _dog;
_swimmerObj setdir _dir;

// **************************************************************************
// attach dog to object
// **************************************************************************
_dog enablesimulation false;
_dog setposasl [_pos select 0, _pos select 1, -.5];
_swimmerObj setpos [getpos _dog select 0, (getpos _dog select 1)+1, 5];
_dog attachTo [_swimmerObj, [0,-1,-5.65]];
//diag_log [getpos _dog, getpos _swimmerObj];
_dog enablesimulation true;

// **************************************************************************
// Move the dog  and (_dog distance _moveToPos) > 2
// **************************************************************************
_dog playMove "Dog_Run";
_xx = 0;
_dog setVariable ["vIsSwimming", true, true];
// point dog in direction of MoveThere command or Heel command.  Need away to redirect dog too!!!!!!
_dirTo = [_swimmerObj, (_dog getVariable "vMoveToPos")] call BIS_fnc_DirTo;
_swimmerObj setDir _dirTo;
_prevMoveToPos = _dog getVariable "vMoveToPos";
_handler = _dog getVariable "vHandler";
while {(surfaceIsWater (getpos _swimmerObj) and alive _dog) and (getposasl _dog select 2) <= -.5 and _dog getVariable "vIsSwimming"} do
{
   _xx = _xx + 1;
   _dog playMove "Dog_Run";
   _dir = getdir _swimmerObj;
   //_swimmerObj setpos [getpos _swimmerObj select 0, (getpos _swimmerObj select 1)+1, 5]; // keep dog from submerging
   if (surfaceIsWater (getpos _handler) and alive _handler and vehicle _handler == _handler) then
   {
   //and (getTerrainHeightASL getPos _handler) < -1
        if (_dog getVariable "vCommand" == "getin") then
        {
            _swimmerObj setdir ([_dog ,_dog getVariable "vVehicle"] call BIS_fnc_dirTo);
            if (_dog distance (_dog getVariable "vVehicle") < 7) then 
            {
                _dog setVariable ["vIsSwimming", false, true];  // end swim loop
            };
        } else
        {
            if (_dog distance _handler > 8 and (getTerrainHeightASL getPos _handler) < -1) then  // dog swims same dir as handler if near him, else dog swims towards handler
            {
                //_dir = getdir _handler;
                //_swimmerObj setdir _dir;
                _dir = ([_dog, _handler modelToWorld [-1.3,4,0]] call BIS_fnc_dirTo);
                _swimmerObj setdir _dir;
            } else
            {
                _dir = ([_dog, _handler modelToWorld [-1.3,-2,0]] call BIS_fnc_dirTo);
                _swimmerObj setdir _dir; 
            };
        };
   };
   if !(vehicle _handler == _handler) then  // hail mary to fix dog swim forever while handler in boat
   {
        _dog setVariable ["vIsSwimming", false, true]; 
   };
   _zVel = 0;
//_swimmerObj setpos [getpos _swimmerObj select 0, (getpos _swimmerObj select 1), 5];  // didn't work...too jerky
   if (getposasl _swimmerObj select 2 < 5) then {_zVel = .4;};
   _swimmerObj setVelocity [_speed * sin(_dir), _speed * cos(_dir), _zVel];  
   //_swimmerObj setVelocityModelSpace [0, 0, _zVel];  // didn't work
   sleep _sleepTime;
};
// **************************************************************************
// Delete the physics object
// **************************************************************************
detach _dog;
deleteVehicle _swimmerObj;
/*
if (vehicle _handler != _handler) then
{
    _dog setVariable ["vCommand", "getin", true]; 
    _dog setVariable ["vVehicle", vehicle _handler, true];
    _dog setpos ((getpos vehicle _handler) vectorAdd [-3,0,0]);
    _dog playMove "Dog_Stop";
} else
{
*/
    _dog playMoveNow "Dog_Sit";
    //_dog playMove "Dog_Stop";
    // *******************************************************
    // Move dog onto picnic table
    // *******************************************************
    _dog setVariable ["vIsSwimming", false, true]; 
        _dog setVariable ["vSilentCommand",true,true];
        //_dog setVariable ["vCommand","stay",true];
        //sleep 1;
        _dog setVariable ["vCommand", "heel", true]; 
        sleep 2;
        _dog setVariable ["vSilentCommand",false,true];
 //};