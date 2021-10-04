//
//  CheckWXData.swift
//  API Fetching
//
//  Created by Larissa Perara on 3/9/21.
//

import Foundation
/**
 Decoded
 API Response
 ×
 {
 "data": [
 {
 "barometer":
 {
 "hg": 30.44,
 "hpa": 1031,
 "kpa": 103.08,
 "mb": 1030.82
 },
 "clouds": [
 {
 "code": "CLR",
 "text": "Clear skies"
 }],
 "conditions": [],
 "dewpoint": {
 "celsius": -2,
 "fahrenheit": 28
 },
 "elevation": {
 "feet": 30,
 "meters": 9
 },
 "flight_category": "VFR",
 "humidity": {
 "percent": 53
 },
 "icao": "KLGA",
 "location": {
 "coordinates": [
 -73.872597,
 40.777199
 ],
 "type": "Point"
 },
 "observed": "2021-03-10T04:51:00.000Z",
 "radius": {
 "bearing": 333,
 "from": "KJFK",
 "meters": 17218,
 "miles": 10.698769187942416
 },
 "raw_text": "KLGA 100451Z 06004KT 10SM CLR 07/M02 A3044 RMK AO2 SLP306 T00671022 401670056",
 "station": {
 "name": "La Guardia Airport"
 },
 ....z
 }
 */

// Simply as an exercise to map out the query we inputted to the final result
typealias IACODataSummary = (query: String, list: [IACODataModel.DataSubsetContainer])

class IACODataModel {
    
    // MARK: - Public Variables
    static let shared = IACODataModel()
    let session = URLSession.shared
    public var dataSummary: IACODataSummary?
    
    // MARK: - Codable Structs for JSON Mapping
    
    /**
     We can use Codable to map a JSON data into a struct without much work if we keep to the supported types:
     String, Int, Double, URL, Date, Data, Array and Dictionary.
     As long as the variable name maps to the json key we don't have to do a custom mapping.
     
     This write up is not created as a testiment to my developer knowledge, but made for students to use, play around with, and learn. It is by no means the cleanest or most efficient, opmitized on the ability to students to find patterns to solidfy concepts.
     */
    
    /**
     Our data is a key, value pair of "data": [{"iaco": {}, "raw_text": {}}...]
     Therefore, we need to get the data as an array of subelements, those sub-elments
     can have any of the properties mentioned above.
     
     Cheat sheet:
     - If its contained by {} it is a Dictionary [String: String],
     - If it is contained by [] then you can use an Array of a new codable object, or another type listed above i.e. [String]
     - If its is simply "text": "..." then this is mapped to just a simple variable of one of the simplier types
     */
    
    struct DataSetContainer: Codable {
        var data: [DataSubsetContainer] // "data: [{}]"
    }
   
    /**
     This data subset
     i.e. in the JSON this - "icao": "KLGA" >> var iaco: String in the Codabe struct
     
     Covered properties at the moment intime {"iaco": "", "raw_text": "", "clouds": [{...}]}
     */
    struct DataSubsetContainer: Codable {
        var icao: String // "iaco": ""
        var clouds: [CloudDataSet] // "clouds": [{ "code": "CLR", "text": "Clear skies"}]
        var stationName: String // "station": {"name": "La Guardia Airport"}
        
        // Custom mapping needed
        var singleLine: String // "raw_text": ""

        enum CustomCodingKeys: String, CodingKey {
            case icao, clouds, station, singleLine = "raw_text"
        }
        
        enum StationCodingKeys: String, CodingKey {
            case name
        }
        
        // Init is only necessary if you want or need a custome mapping or complex mappings
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CustomCodingKeys.self)
            icao = try container.decode(String.self, forKey: .icao)
            clouds = try container.decode([CloudDataSet].self, forKey: .clouds)
            singleLine = try container.decode(String.self, forKey: .singleLine)

            let stationContaniter = try container.nestedContainer(keyedBy: StationCodingKeys.self, forKey: .station)
            stationName = try stationContaniter.decode(String.self, forKey: .name)
        }
    }
    
   
    
    
    /** We can still map things that are in a sub **array** within the json as shown below.
        Note that we have to in the decoder above (if we need a customer
     
        Example: "clouds": [{"code": "CLR", "text": "Clear skies"}]
        Some other from the data set that this sort of setup would be applicable to are: coordinates
     */
    struct CloudDataSet: Codable {
        var code: String
        var description: String
        
        enum CustomMapping: String, CodingKey {
            case code, description = "text"
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CustomMapping.self)
            code = try container.decode(String.self, forKey: .code)
            description = try container.decode(String.self, forKey: .description)
        }
    }
    
    // MARK: - Initializers
    
    init() {
        // Not the proper way to do this, but is fine for this example
        print("CheckWXDataManager Instantiated")
    }
    
    // MARK: - Public APIs for Data Fetching
    
    // For simplicity's sake for htis demo, the expected input is a string following this format:
    // "KMHR,KMCC,KAUN,KPVF"
    public func requestIACOData(_ icao: String, completion: @escaping ((_ data: String?) -> Void)) {
        // Check to see if the data is already loaded, if it is, pass back the previously saved entry
        // Note: This should really be done in a manager class or some class that will persist between sessions
        // and is invoked in bootstrap
//        if dataSummary != nil {
//            completion(dataSummaryToString())
//        }
//        else {
            loadJSONData(getAPIRequest(icao)) { data in
                guard let requestedData = data else {
                    completion(nil)
                    return
                }
                
                completion(requestedData)
                return
            }
     //   } For right now: As you debug and learn, I am turing off the "save" feature
    }
    
}

// MARK: - Private API & Data Handling Helper Functions

extension IACODataModel {
    
    private func dataSummaryToString() -> String {
        guard let list = dataSummary?.list else {
            return "No data list"
        }
        
        let iacoMap: [String] = list.map { $0.singleLine }
        let aggregatedLine = iacoMap.joined(separator: "\n\n\n")
        return aggregatedLine
        
        /* This can actually be turned into simply a single line.
         But I have variables for you to see the different parts and be able to
         debug to deermine what each step is doing and what that looks like. */
        // return list.map { $0.singleLine }.joined(separator: ",")
    }
    
    private func getFullData() -> String {
        guard let list = dataSummary?.list else {
            print("list is DNE")
            return ""
        }
        
        var returnString = String()
        for airport in list {
            returnString.append(printAirportData(airport))
        }
        
        return returnString
    }
    
    private func printAirportData(_ subset: DataSubsetContainer) -> String {
        var stringToPrint = String()
        stringToPrint.append("----\(subset.stationName)-----\n")
        stringToPrint.append("\(subset.icao): \(subset.singleLine) \n")
        stringToPrint.append(" Weather: \(subset.clouds[0].code), \(subset.clouds[0].description)\n\n")
        return stringToPrint
    }
    
    private func getAPIRequest(_ iacos: String) -> URLRequest? {
        let urlString = "https://api.checkwx.com/metar/" + iacos + "/decoded/"
        // print("URL String: \(urlString)")
        
        // Better way to write it, however, this lets us print out the end point for learning purposes
        //  guard let endpoint = URL("https://api.checkwx.com/metar/" + iacos + "/decoded/") else
        
        guard let endpoint = URL(string: urlString) else {
            print("Could not make a URL")
            return nil
        }
        
        var request = URLRequest(url: endpoint)
        request.addValue("76703a416bca4a9c88f21e67ef", forHTTPHeaderField: "X-API-Key")
        request.httpMethod = "GET"
        return request
    }
    
    
    private func loadJSONData(_ request: URLRequest?, completion: @escaping ((_ data: String?) -> Void)) {
        guard let request = request else {
            completion(nil)
            return
        }
        
        session.dataTask(with: request) { [weak self, completion, request] data, response, error in
            guard let strongSelf = self else {
                print("Lost self")
                completion(nil)
                return
            }
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode),
                  error == nil,
                  let taskData = data else {
                print("Task Failed: response - \(String(describing: response)), error - \(String(describing: error))")
                completion(nil)
                return
            }
            do {
                let dataArray = try JSONDecoder().decode(DataSetContainer.self, from: taskData)
                
                // print("We have decoded a data array with count: \(dataArray.data.count)")
                
                strongSelf.dataSummary = IACODataSummary(query: request.description, list: dataArray.data)
                
                // let string = strongSelf.dataSummaryToString() - This will aggregate the IACO raw text into a string
                //print("String we are passing back to the front end: \(string)")
                
                completion(strongSelf.getFullData()) // Same thing here, these variables are not truly needed, but created for learning and exploration.
                
            } catch {
                print("Error: decoded json")
                completion(nil)
                return
            }
        }.resume()
    }
}
