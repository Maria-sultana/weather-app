import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:jiffy/jiffy.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Position position;
  Map<String, dynamic>? weatherMap;
  Map<String, dynamic>? forecastMap;

  determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    position = await Geolocator.getCurrentPosition();
    setState(() {
      latitude = position.latitude;
      longatute = position.longitude;
    });
    fetchWeatherData();
  }

  var latitude;
  var longatute;

  fetchWeatherData() async {
    String forecastUrl =
        "https://api.openweathermap.org/data/2.5/forecast?lat=$latitude&lon=$longatute&units=metric&appid=f92bf340ade13c087f6334ed434f9761&fbclid=IwAR2MIhWnKnisutHJ1y1dgxc-XbFFbVlG_T_f8F9_fhd6ZFC4PRI3oNAWgMc";

    String weatherUrl =
        "https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longatute&units=metric&appid=f92bf340ade13c087f6334ed434f9761&fbclid=IwAR2MIhWnKnisutHJ1y1dgxc-XbFFbVlG_T_f8F9_fhd6ZFC4PRI3oNAWgMc";

    var weatherResponce = await http.get(Uri.parse(weatherUrl));

    var forecastResponce = await http.get(Uri.parse(forecastUrl));
    weatherMap = Map<String, dynamic>.from(jsonDecode(weatherResponce.body));
    forecastMap = Map<String, dynamic>.from(jsonDecode(forecastResponce.body));
    setState(() {});
    print("eeeeeeeeeee${forecastMap!["cod"]}");
  }

  @override
  void initState() {
    // TODO: implement initState
    determinePosition();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
    
      child: forecastMap != null
          ? Scaffold(
            appBar: AppBar(
              title: Center(child: Text("Weather App",style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),)),
              elevation: 0,
              backgroundColor: Colors.white,
              actions: [
               Container(height: 50,
                width: 50,
                 decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.grey,
                  border: Border.all(color: Colors.black,width: 2)
                  ),
                  child:Icon(Icons.menu_outlined),)
              ],
            ),
            
              body: Container(
                width: double.infinity,
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  image: DecorationImage(image: NetworkImage("https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTKymSwMAtoriTo76fMO3DAv5DLmZoyeq3MSw&usqp=CAU"),fit: BoxFit.cover)
                ),
                
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      color: Colors.grey.withOpacity(0.5),
                      child: TextFormField(
                        decoration:InputDecoration(
    border: OutlineInputBorder(),
    hintText: 'Search your location',
    icon: Icon(Icons.search),
    iconColor: Colors.black
  ),
                      ),
                    ),
                    
                    Align(
                      alignment: Alignment.topRight,
                      child: Container(
                        height:150,
                        width: 200,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(10),
                          
                        ),
                       
                        
                        
                        child: Column(
                          
                          children: [
                          SizedBox(height: 50,),
                            Center(
                            
                              child: Text(
                                  "${Jiffy(DateTime.now()).format("MMM do yy")} , ${Jiffy(DateTime.now()).format("h:mm")}",style: TextStyle(fontWeight: FontWeight.bold),),
                            ),
                            SizedBox(width: 10,),
                            Text("${weatherMap!["name"]}",style: TextStyle(fontWeight: FontWeight.bold),),
                            Icon(Icons.pin_drop_outlined,size: 50,)
                          
                          ],
                        ),
                      ),
                    ),
                   
                        Text(
                          "|| ${weatherMap!["main"]["temp"]}°||",
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        
                 
                      Align(
                        alignment: Alignment.center,
                        child: Column(
                          
                          children: [
                          Container(
                            height: 100,
                            width: 150,
                            child: 
                            Text("Feels Like ${weatherMap!["main"]["feels_like"]},"),
                          decoration: BoxDecoration(
                          
                        borderRadius: BorderRadius.circular(10),
                               color: Colors.grey.withOpacity(0.5),
                               
                            ),),
                           
                          
                        ]),
                      ),
                    
                    Row(
                      children: [
                        Container(
                          height: 100,
                          width: 150,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.grey.withOpacity(0.5),
                          ),
                          child: Text(
                              "Humidity ${weatherMap!["main"]["humidity"]}, \nPressure ${weatherMap!["main"]["pressure"]},",style: TextStyle(fontWeight: FontWeight.bold,),
                        )),
                          SizedBox(width: 50,),
                    Container(
                      height: 100,
                      width: 150,
                       decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.grey.withOpacity(0.5),
                          ),
                          
                      child: Text(
                          "Sunrise ${Jiffy("${DateTime.fromMicrosecondsSinceEpoch(weatherMap!["sys"]["sunrise"] * 1000)}").format("h:mm a")} , Sunset ${Jiffy("${DateTime.fromMicrosecondsSinceEpoch(weatherMap!["sys"]["sunset"] * 1000)}").format("h:mm a")}",style: TextStyle(fontWeight: FontWeight.bold,),
                    ),
                    )
                      ],
                    ),
                  
                    SizedBox(
                      height: 200,
                      child: ListView.builder(
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          itemCount: forecastMap!.length,
                          itemBuilder: (context, index) {
                            var x = forecastMap!["list"][index]["weather"][0]
                                ["icon"];
                            return Container(
                              width: 200,
                              child: Column(
                                children: [
                                  Container(
                                    height: 0,
                                    width:50 ,
                                   decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                     color: Colors.grey.withOpacity(0.5),
                                   ),
                                    child: 
                                     
                                       Text(
                                          "${Jiffy(forecastMap!["list"][index]["dt_txt"]).format("EEE h:mm")}" ),
                                    
                                  ),SizedBox(width: 10,),

                                  Text(
                                      "${forecastMap!["list"][index]["main"]["temp_min"]}  ${forecastMap!["list"][index]["main"]["temp_max"]} °  "),
                                  Image.network(
                                      "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRvLTO9FSuLclwIoefm51WpuBZHNyu6w-3ceQ&usqp=CAU",
                                      ),
                              
                                  Text(
                                      "${forecastMap!["list"][index]["weather"][0]["description"]}"),
                                      Image.network("https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRvLTO9FSuLclwIoefm51WpuBZHNyu6w-3ceQ&usqp=CAU"),
                                    
                                
                                ],
                              ),
                            );
                          }),
                    )
                  ],
                ),
              ),
            )
          : Center(child: CircularProgressIndicator()),
    );
  }
}

      
    