import 'choice_manager.dart';

class ScenarioTitles {
  static const String cityStreet = 'City Street';
  static const String suburbanStreet = 'Suburban Street';
  static const String neighborhoodStreet = 'Neighborhood Street';
}

List<Option> getStaticOptions(String title) {
  switch (title) {
    case ScenarioTitles.cityStreet:
      return cityStreetStaticOptions;
    case ScenarioTitles.suburbanStreet:
      return cityStreetStaticOptions;
    default:
      return [];
  }
}

Map<String, LaneManager> getScenarioOptions(String title) {
  switch (title) {
    case ScenarioTitles.cityStreet:
      return cityStreetOptions;
    case ScenarioTitles.suburbanStreet:
      return suburbanStreetOptions;
    default:
      return {};
  }
}

List<Option> cityStreetStaticOptions = [
  Option([
    [OptionImage(layer: 0, imagePath: 'assets/sky_default.png')]
  ], null, 0),
  Option([
    [OptionImage(layer: 1, imagePath: 'assets/road.png')]
  ], null, 0),
  Option([
    [OptionImage(layer: 2, imagePath: 'assets/crosswalk_far_default.png')]
  ], null, 0),
  Option([
    [OptionImage(layer: 3, imagePath: 'assets/sidewalk_default.png')]
  ], null, 0),
  Option([
    [OptionImage(layer: 5, imagePath: 'assets/fog.png')]
  ], null, 0),
  Option([
    [OptionImage(layer: 6, imagePath: 'assets/traffic_signal.png')]
  ], null, 0),
];

Map<String, LaneManager> cityStreetOptions = {
  LaneNames.lane1: LaneManager([
    ChoiceManager([
      Feature([
        Option([
          [
            OptionImage(layer: 2, imagePath: 'assets/bikelane_outer_L.png'),
            OptionImage(
                layer: 5, imagePath: 'assets/cyclist_frontfacing_outer.png')
          ]
        ], 'assets/bikelane_preview.png'),
        Option([
          [
            OptionImage(
                layer: 2, imagePath: 'assets/bikelane_outer_green_L.png'),
            OptionImage(
                layer: 5, imagePath: 'assets/cyclist_frontfacing_outer.png')
          ]
        ], 'assets/bikelane_green_preview.png')
      ]),
    ], "Bike Lane", BikeLane.onEnableOuterL, BikeLane.onDisableOuterL),
    ChoiceManager([
      //Bus Lane paint type
      Feature([
        Option([
          [
            OptionImage(layer: 2, imagePath: 'assets/buslane_outer_L.png'),
            OptionImage(layer: 5, imagePath: 'assets/Bus_outer_L.png')
          ]
        ], 'assets/buslane_preview.png', 100, OptionTypes.wide.index),
        Option([
          [
            OptionImage(layer: 2, imagePath: 'assets/buslane_outer_red_L.png'),
            OptionImage(layer: 5, imagePath: 'assets/Bus_outer_L.png')
          ]
        ], 'assets/buslane_red_preview.png', 100, OptionTypes.wide.index)
      ], 0),
    ], "Bus Lane", BusLane.onEnableOuterL, BusLane.onDisableOuterL),
    ChoiceManager([
      //type of parking
      Feature([
        Option([
          [
            OptionImage(
                layer: 3, imagePath: 'assets/parking_parallel_outer_L.png'),
            OptionImage(
                layer: 6, imagePath: 'assets/white_volvo_parallel_outer_L.png')
          ]
        ], 'assets/parking_parallel_preview.png'),
        Option([
          [
            OptionImage(layer: 3, imagePath: 'assets/parking_diagonal_L.png'),
            OptionImage(
                layer: 6, imagePath: 'assets/white_volvo_diagonal_L.png'),
          ]
        ], 'assets/parking_diagonal_preview.png', 100, OptionTypes.wide.index,
            DiagonalParking.onEnableOuterL, DiagonalParking.onDisableOuterL)
      ]),
    ], "On-Street Parking", Parking.onEnableOuterL, Parking.onDisableOuterL),
    ChoiceManager([
      Feature([
        Option([
          [OptionImage(layer: 4, imagePath: 'assets/sidewalk_extension_L.png')]
        ], 'assets/sidewalk_extension_L.png'),
      ], 0),
      Feature([
        Option([
          [
            OptionImage(layer: 7, imagePath: 'assets/trees_near_L.png'),
            OptionImage(layer: 5, imagePath: 'assets/trees_far_L.png')
          ],
        ], 'assets/trees_near_L.png', 100, OptionTypes.extra.index),
      ]),
    ], "Sidewalk", Sidewalk.onEnableL, Sidewalk.onDisableL),
  ], Lane1.onEnable, Lane1.onDisable),
  LaneNames.lane2: LaneManager([
    ChoiceManager([
      //Bike lane paint type
      Feature([
        Option([
          [
            OptionImage(layer: 2, imagePath: 'assets/bikelane_mid_L.png'),
            OptionImage(
                layer: 5, imagePath: 'assets/cyclist_frontfacing_mid.png')
          ],
          [
            OptionImage(layer: 2, imagePath: 'assets/bikelane_inner_L.png'),
            OptionImage(
                layer: 5, imagePath: 'assets/cyclist_frontfacing_inner.png')
          ],
        ], 'assets/bikelane_preview.png'),
        Option([
          [
            OptionImage(layer: 2, imagePath: 'assets/bikelane_mid_green_L.png'),
            OptionImage(
                layer: 5, imagePath: 'assets/cyclist_frontfacing_mid.png')
          ],
          [
            OptionImage(
                layer: 2, imagePath: 'assets/bikelane_inner_green_L.png'),
            OptionImage(
                layer: 5, imagePath: 'assets/cyclist_frontfacing_inner.png')
          ]
        ], 'assets/bikelane_green_preview.png')
      ]),
    ], "Bike Lane", BikeLane.onEnableInnerL, BikeLane.onDisableInnerL),
    ChoiceManager([
      //Bus Lane paint type
      Feature([
        Option([
          [
            OptionImage(layer: 2, imagePath: 'assets/buslane_inner_L.png'),
            OptionImage(layer: 5, imagePath: 'assets/Bus_inner_L.png')
          ]
        ], 'assets/buslane_preview.png', 100, OptionTypes.wide.index),
        Option([
          [
            OptionImage(layer: 2, imagePath: 'assets/buslane_inner_red_L.png'),
            OptionImage(layer: 5, imagePath: 'assets/Bus_inner_L.png')
          ]
        ], 'assets/buslane_red_preview.png', 100, OptionTypes.wide.index)
      ], 0),
    ], "Bus Lane", BusLane.onEnableInnerL, BusLane.onDisableInnerL),
    ChoiceManager([
      Feature([
        Option([
          [
            OptionImage(
                layer: 3, imagePath: 'assets/parking_parallel_mid_L.png'),
            OptionImage(
                layer: 6, imagePath: 'assets/white_volvo_parallel_mid_L.png')
          ],
          [
            OptionImage(
                layer: 3, imagePath: 'assets/parking_parallel_inner_L.png'),
            OptionImage(
                layer: 6, imagePath: 'assets/white_volvo_parallel_inner_L.png')
          ]
        ], 'assets/parking_parallel_preview.png'),
        Option([
          [
            OptionImage(
                layer: 3, imagePath: 'assets/parking_diagonal_inner_L.png'),
            OptionImage(
                layer: 6, imagePath: 'assets/white_volvo_diagonal_inner_L.png'),
          ]
        ], 'assets/parking_diagonal_preview.png', 100, OptionTypes.wide.index,
            DiagonalParking.onEnableInnerL, DiagonalParking.onDisableInnerL)
      ]),
    ], "On-Street Parking", Parking.onEnableInnerL, Parking.onDisableInnerL),
  ], Lane2.onEnable, Lane2.onDisable),
  LaneNames.lane3: LaneManager([
    ChoiceManager([
      Feature([
        Option([
          [OptionImage(layer: 2, imagePath: 'assets/median_yellowlines.png')]
        ], 'assets/median_yellowlines_preview.png'),
        Option([
          [OptionImage(layer: 2, imagePath: 'assets/median_concrete.png')]
        ], 'assets/median_concrete_preview.png')
      ]),
    ], "Median", null, null, true, true),
  ], Lane3.onEnable, Lane3.onDisable),
  LaneNames.lane4: LaneManager([
    ChoiceManager([
      //Bike lane paint type
      Feature([
        Option([
          [
            OptionImage(layer: 2, imagePath: 'assets/bikelane_mid_R.png'),
            OptionImage(
                layer: 5, imagePath: 'assets/cyclist_rearfacing_mid.png')
          ],
          [
            OptionImage(layer: 2, imagePath: 'assets/bikelane_inner_R.png'),
            OptionImage(
                layer: 5, imagePath: 'assets/cyclist_rearfacing_inner.png')
          ],
        ], 'assets/bikelane_preview.png'),
        Option([
          [
            OptionImage(layer: 2, imagePath: 'assets/bikelane_mid_green_R.png'),
            OptionImage(
                layer: 5, imagePath: 'assets/cyclist_rearfacing_mid.png')
          ],
          [
            OptionImage(
                layer: 2, imagePath: 'assets/bikelane_inner_green_R.png'),
            OptionImage(
                layer: 5, imagePath: 'assets/cyclist_rearfacing_inner.png')
          ]
        ], 'assets/bikelane_green_preview.png')
      ]),
    ], "Bike Lane", BikeLane.onEnableInnerR, BikeLane.onDisableInnerR),
    ChoiceManager([
      //Bus Lane paint type
      Feature([
        Option([
          [
            OptionImage(layer: 2, imagePath: 'assets/buslane_inner_R.png'),
            OptionImage(layer: 5, imagePath: 'assets/Bus_inner_R.png')
          ]
        ], 'assets/buslane_preview.png', 100, OptionTypes.wide.index),
        Option([
          [
            OptionImage(layer: 2, imagePath: 'assets/buslane_inner_red_R.png'),
            OptionImage(layer: 5, imagePath: 'assets/Bus_inner_R.png')
          ]
        ], 'assets/buslane_red_preview.png', 100, OptionTypes.wide.index)
      ], 0),
    ], "Bus Lane", BusLane.onEnableInnerR, BusLane.onDisableInnerR),
    ChoiceManager([
      //type of parking
      Feature([
        Option([
          [
            OptionImage(
                layer: 3, imagePath: 'assets/parking_parallel_mid_R.png'),
            OptionImage(
                layer: 6, imagePath: 'assets/white_volvo_parallel_mid_R.png')
          ],
          [
            OptionImage(
                layer: 3, imagePath: 'assets/parking_parallel_inner_R.png'),
            OptionImage(
                layer: 6, imagePath: 'assets/white_volvo_parallel_inner_R.png')
          ]
        ], 'assets/parking_parallel_preview.png'),
        Option([
          [
            OptionImage(
                layer: 3, imagePath: 'assets/parking_diagonal_inner_R.png'),
            OptionImage(
                layer: 6, imagePath: 'assets/white_volvo_diagonal_inner_R.png'),
          ]
        ], 'assets/parking_diagonal_preview.png', 100, OptionTypes.wide.index,
            DiagonalParking.onEnableInnerR, DiagonalParking.onDisableInnerR)
      ]),
    ], "On-Street Parking", Parking.onEnableInnerR, Parking.onDisableInnerR),
  ], Lane4.onEnable, Lane4.onDisable),
  LaneNames.lane5: LaneManager([
    ChoiceManager([
      //Bike lane paint type
      Feature([
        Option([
          [
            OptionImage(layer: 2, imagePath: 'assets/bikelane_outer_R.png'),
            OptionImage(
                layer: 5, imagePath: 'assets/cyclist_rearfacing_outer.png')
          ]
        ], 'assets/bikelane_preview.png'),
        Option([
          [
            OptionImage(
                layer: 2, imagePath: 'assets/bikelane_outer_green_R.png'),
            OptionImage(
                layer: 5, imagePath: 'assets/cyclist_rearfacing_outer.png')
          ]
        ], 'assets/bikelane_green_preview.png')
      ]),
    ], "Bike Lane", BikeLane.onEnableOuterR, BikeLane.onDisableOuterR),
    ChoiceManager([
      Feature([
        Option([
          [
            OptionImage(layer: 2, imagePath: 'assets/buslane_outer_R.png'),
            OptionImage(layer: 5, imagePath: 'assets/Bus_outer_R.png')
          ]
        ], 'assets/buslane_preview.png', 100, OptionTypes.wide.index),
        Option([
          [
            OptionImage(layer: 2, imagePath: 'assets/buslane_outer_red_R.png'),
            OptionImage(layer: 5, imagePath: 'assets/Bus_outer_R.png')
          ]
        ], 'assets/buslane_red_preview.png', 100, OptionTypes.wide.index)
      ], 0),
    ], "Bus Lane", BusLane.onEnableOuterR, BusLane.onDisableOuterR),
    ChoiceManager([
      Feature([
        Option([
          [
            OptionImage(
                layer: 3, imagePath: 'assets/parking_parallel_outer_R.png'),
            OptionImage(
                layer: 6, imagePath: 'assets/white_volvo_parallel_outer_R.png')
          ]
        ], 'assets/parking_parallel_preview.png'),
        Option([
          [
            OptionImage(layer: 3, imagePath: 'assets/parking_diagonal_R.png'),
            OptionImage(
                layer: 6, imagePath: 'assets/white_volvo_diagonal_R.png'),
          ]
        ], 'assets/parking_diagonal_preview.png', 100, OptionTypes.wide.index,
            DiagonalParking.onEnableOuterR, DiagonalParking.onDisableOuterR)
      ]),
    ], "On-Street Parking", Parking.onEnableOuterR, Parking.onDisableOuterR),
    ChoiceManager([
      Feature([
        Option([
          [OptionImage(layer: 4, imagePath: 'assets/sidewalk_extension_R.png')]
        ], 'assets/sidewalk_extension_R.png'),
      ], 0),
      Feature([
        Option([
          [
            OptionImage(layer: 7, imagePath: 'assets/trees_near_R.png'),
            OptionImage(layer: 5, imagePath: 'assets/trees_far_R.png')
          ],
        ], 'assets/trees_near_R.png', 100, OptionTypes.extra.index),
      ]),
      Feature([
        Option([
          [
            OptionImage(layer: 7, imagePath: 'assets/bollard_R.png'),
          ],
        ], 'assets/bollard_preview.png', 100, OptionTypes.extra.index),
      ])
    ], "Sidewalk", Sidewalk.onEnableR, Sidewalk.onDisableR),
  ], Lane5.onEnable, Lane5.onDisable),
  LaneNames.crosswalk: LaneManager([
    ChoiceManager([
      Feature(
        [
          Option([
            [
              OptionImage(layer: 6, imagePath: 'assets/crosswalk_L.png'),
              OptionImage(layer: 6, imagePath: 'assets/crosswalk_R.png')
            ],
            [
              OptionImage(
                  layer: 6, imagePath: 'assets/crosswalk_extended_L.png'),
              OptionImage(
                  layer: 6, imagePath: 'assets/crosswalk_extended_R.png')
            ],
          ], 'assets/crosswalk_default_preview.png'),
        ],
      ),
      Feature(
        [
          Option([
            [OptionImage(layer: 5, imagePath: 'assets/crosswalk_lines.png')]
          ], 'assets/crosswalk_lines_preview.png'),
        ],
      ),
    ], "Crosswalk", null, null, true, true),
  ], Crosswalk.onEnable, Crosswalk.onDisable),
  LaneNames.buildings: LaneManager([
    ChoiceManager([
      Feature([
        Option([
          [OptionImage(layer: 4, imagePath: 'assets/brownstone_building.png')]
        ], 'assets/brownstone_building_preview.png'),
        Option([
          [OptionImage(layer: 4, imagePath: 'assets/condo_whiteandred.png')]
        ], 'assets/condo_whiteandred_preview.png'),
      ]),
    ], "Buildings", null, null, true, true)
  ], Buildings.onEnable, Buildings.onDisable),
};

Map<String, LaneManager> suburbanStreetOptions = {
  LaneNames.lane1: LaneManager([
    ChoiceManager([
      Feature([
        Option([
          [
            OptionImage(layer: 2, imagePath: 'assets/bikelane_outer_L.png'),
            OptionImage(
                layer: 5, imagePath: 'assets/cyclist_frontfacing_outer.png')
          ]
        ], 'assets/bikelane_preview.png'),
      ]),
    ], "Bike Lane", BikeLane.onEnableOuterL, BikeLane.onDisableOuterL),
    ChoiceManager([
      //Bus Lane paint type
      Feature([
        Option([
          [
            OptionImage(layer: 2, imagePath: 'assets/buslane_outer_L.png'),
            OptionImage(layer: 5, imagePath: 'assets/Bus_outer_L.png')
          ]
        ], 'assets/buslane_preview.png', 100, OptionTypes.wide.index),
        Option([
          [
            OptionImage(layer: 2, imagePath: 'assets/buslane_outer_red_L.png'),
            OptionImage(layer: 5, imagePath: 'assets/Bus_outer_L.png')
          ]
        ], 'assets/buslane_red_preview.png', 100, OptionTypes.wide.index)
      ], 0),
    ], "Bus Lane", BusLane.onEnableOuterL, BusLane.onDisableOuterL),
    ChoiceManager([
      //type of parking
      Feature([
        Option([
          [
            OptionImage(
                layer: 3, imagePath: 'assets/parking_parallel_outer_L.png'),
            OptionImage(
                layer: 6, imagePath: 'assets/white_volvo_parallel_outer_L.png')
          ]
        ], 'assets/parking_parallel_preview.png'),
        Option([
          [
            OptionImage(layer: 3, imagePath: 'assets/parking_diagonal_L.png'),
            OptionImage(
                layer: 6, imagePath: 'assets/white_volvo_diagonal_L.png'),
          ]
        ], 'assets/parking_diagonal_preview.png', 100, OptionTypes.wide.index,
            DiagonalParking.onEnableOuterL, DiagonalParking.onDisableOuterL)
      ]),
    ], "On-Street Parking", Parking.onEnableOuterL, Parking.onDisableOuterL),
    ChoiceManager([
      Feature([
        Option([
          [OptionImage(layer: 4, imagePath: 'assets/sidewalk_extension_L.png')]
        ], 'assets/sidewalk_extension_L.png'),
      ], 0),
      Feature([
        Option([
          [
            OptionImage(layer: 7, imagePath: 'assets/trees_near_L.png'),
            OptionImage(layer: 5, imagePath: 'assets/trees_far_L.png')
          ],
        ], 'assets/trees_near_L.png', 100, OptionTypes.extra.index),
      ]),
    ], "Sidewalk", Sidewalk.onEnableL, Sidewalk.onDisableL),
  ], Lane1.onEnable, Lane1.onDisable),
  LaneNames.lane2: LaneManager([
    ChoiceManager([
      //Bike lane paint type
      Feature([
        Option([
          [
            OptionImage(layer: 2, imagePath: 'assets/bikelane_mid_L.png'),
            OptionImage(
                layer: 5, imagePath: 'assets/cyclist_frontfacing_mid.png')
          ],
          [
            OptionImage(layer: 2, imagePath: 'assets/bikelane_inner_L.png'),
            OptionImage(
                layer: 5, imagePath: 'assets/cyclist_frontfacing_inner.png')
          ],
        ], 'assets/bikelane_preview.png'),
        Option([
          [
            OptionImage(layer: 2, imagePath: 'assets/bikelane_mid_green_L.png'),
            OptionImage(
                layer: 5, imagePath: 'assets/cyclist_frontfacing_mid.png')
          ],
          [
            OptionImage(
                layer: 2, imagePath: 'assets/bikelane_inner_green_L.png'),
            OptionImage(
                layer: 5, imagePath: 'assets/cyclist_frontfacing_inner.png')
          ]
        ], 'assets/bikelane_green_preview.png')
      ]),
    ], "Bike Lane", BikeLane.onEnableInnerL, BikeLane.onDisableInnerL),
    ChoiceManager([
      //Bus Lane paint type
      Feature([
        Option([
          [
            OptionImage(layer: 2, imagePath: 'assets/buslane_inner_L.png'),
            OptionImage(layer: 5, imagePath: 'assets/Bus_inner_L.png')
          ]
        ], 'assets/buslane_preview.png', 100, OptionTypes.wide.index),
        Option([
          [
            OptionImage(layer: 2, imagePath: 'assets/buslane_inner_red_L.png'),
            OptionImage(layer: 5, imagePath: 'assets/Bus_inner_L.png')
          ]
        ], 'assets/buslane_red_preview.png', 100, OptionTypes.wide.index)
      ], 0),
    ], "Bus Lane", BusLane.onEnableInnerL, BusLane.onDisableInnerL),
    ChoiceManager([
      Feature([
        Option([
          [
            OptionImage(
                layer: 3, imagePath: 'assets/parking_parallel_mid_L.png'),
            OptionImage(
                layer: 6, imagePath: 'assets/white_volvo_parallel_mid_L.png')
          ],
          [
            OptionImage(
                layer: 3, imagePath: 'assets/parking_parallel_inner_L.png'),
            OptionImage(
                layer: 6, imagePath: 'assets/white_volvo_parallel_inner_L.png')
          ]
        ], 'assets/parking_parallel_preview.png'),
        Option([
          [
            OptionImage(
                layer: 3, imagePath: 'assets/parking_diagonal_inner_L.png'),
            OptionImage(
                layer: 6, imagePath: 'assets/white_volvo_diagonal_inner_L.png'),
          ]
        ], 'assets/parking_diagonal_preview.png', 100, OptionTypes.wide.index,
            DiagonalParking.onEnableInnerL, DiagonalParking.onDisableInnerL)
      ]),
    ], "On-Street Parking", Parking.onEnableInnerL, Parking.onDisableInnerL),
  ], Lane2.onEnable, Lane2.onDisable),
  LaneNames.lane3: LaneManager([
    ChoiceManager([
      Feature([
        Option([
          [OptionImage(layer: 2, imagePath: 'assets/median_yellowlines.png')]
        ], 'assets/median_yellowlines_preview.png'),
        Option([
          [OptionImage(layer: 2, imagePath: 'assets/median_concrete.png')]
        ], 'assets/median_concrete_preview.png')
      ]),
    ], "Median", null, null, true, true),
  ], Lane3.onEnable, Lane3.onDisable),
  LaneNames.lane4: LaneManager([
    ChoiceManager([
      //Bike lane paint type
      Feature([
        Option([
          [
            OptionImage(layer: 2, imagePath: 'assets/bikelane_mid_R.png'),
            OptionImage(
                layer: 5, imagePath: 'assets/cyclist_rearfacing_mid.png')
          ],
          [
            OptionImage(layer: 2, imagePath: 'assets/bikelane_inner_R.png'),
            OptionImage(
                layer: 5, imagePath: 'assets/cyclist_rearfacing_inner.png')
          ],
        ], 'assets/bikelane_preview.png'),
        Option([
          [
            OptionImage(layer: 2, imagePath: 'assets/bikelane_mid_green_R.png'),
            OptionImage(
                layer: 5, imagePath: 'assets/cyclist_rearfacing_mid.png')
          ],
          [
            OptionImage(
                layer: 2, imagePath: 'assets/bikelane_inner_green_R.png'),
            OptionImage(
                layer: 5, imagePath: 'assets/cyclist_rearfacing_inner.png')
          ]
        ], 'assets/bikelane_green_preview.png')
      ]),
    ], "Bike Lane", BikeLane.onEnableInnerR, BikeLane.onDisableInnerR),
    ChoiceManager([
      //Bus Lane paint type
      Feature([
        Option([
          [
            OptionImage(layer: 2, imagePath: 'assets/buslane_inner_R.png'),
            OptionImage(layer: 5, imagePath: 'assets/Bus_inner_R.png')
          ]
        ], 'assets/buslane_preview.png', 100, OptionTypes.wide.index),
        Option([
          [
            OptionImage(layer: 2, imagePath: 'assets/buslane_inner_red_R.png'),
            OptionImage(layer: 5, imagePath: 'assets/Bus_inner_R.png')
          ]
        ], 'assets/buslane_red_preview.png', 100, OptionTypes.wide.index)
      ], 0),
    ], "Bus Lane", BusLane.onEnableInnerR, BusLane.onDisableInnerR),
    ChoiceManager([
      //type of parking
      Feature([
        Option([
          [
            OptionImage(
                layer: 3, imagePath: 'assets/parking_parallel_mid_R.png'),
            OptionImage(
                layer: 6, imagePath: 'assets/white_volvo_parallel_mid_R.png')
          ],
          [
            OptionImage(
                layer: 3, imagePath: 'assets/parking_parallel_inner_R.png'),
            OptionImage(
                layer: 6, imagePath: 'assets/white_volvo_parallel_inner_R.png')
          ]
        ], 'assets/parking_parallel_preview.png'),
        Option([
          [
            OptionImage(
                layer: 3, imagePath: 'assets/parking_diagonal_inner_R.png'),
            OptionImage(
                layer: 6, imagePath: 'assets/white_volvo_diagonal_inner_R.png'),
          ]
        ], 'assets/parking_diagonal_preview.png', 100, OptionTypes.wide.index,
            DiagonalParking.onEnableInnerR, DiagonalParking.onDisableInnerR)
      ]),
    ], "On-Street Parking", Parking.onEnableInnerR, Parking.onDisableInnerR),
  ], Lane4.onEnable, Lane4.onDisable),
  LaneNames.lane5: LaneManager([
    ChoiceManager([
      //Bike lane paint type
      Feature([
        Option([
          [
            OptionImage(layer: 2, imagePath: 'assets/bikelane_outer_R.png'),
            OptionImage(
                layer: 5, imagePath: 'assets/cyclist_rearfacing_outer.png')
          ]
        ], 'assets/bikelane_preview.png'),
        Option([
          [
            OptionImage(
                layer: 2, imagePath: 'assets/bikelane_outer_green_R.png'),
            OptionImage(
                layer: 5, imagePath: 'assets/cyclist_rearfacing_outer.png')
          ]
        ], 'assets/bikelane_green_preview.png')
      ]),
    ], "Bike Lane", BikeLane.onEnableOuterR, BikeLane.onDisableOuterR),
    ChoiceManager([
      Feature([
        Option([
          [
            OptionImage(layer: 2, imagePath: 'assets/buslane_outer_R.png'),
            OptionImage(layer: 5, imagePath: 'assets/Bus_outer_R.png')
          ]
        ], 'assets/buslane_preview.png', 100, OptionTypes.wide.index),
        Option([
          [
            OptionImage(layer: 2, imagePath: 'assets/buslane_outer_red_R.png'),
            OptionImage(layer: 5, imagePath: 'assets/Bus_outer_R.png')
          ]
        ], 'assets/buslane_red_preview.png', 100, OptionTypes.wide.index)
      ], 0),
    ], "Bus Lane", BusLane.onEnableOuterR, BusLane.onDisableOuterR),
    ChoiceManager([
      Feature([
        Option([
          [
            OptionImage(
                layer: 3, imagePath: 'assets/parking_parallel_outer_R.png'),
            OptionImage(
                layer: 6, imagePath: 'assets/white_volvo_parallel_outer_R.png')
          ]
        ], 'assets/parking_parallel_preview.png'),
        Option([
          [
            OptionImage(layer: 3, imagePath: 'assets/parking_diagonal_R.png'),
            OptionImage(
                layer: 6, imagePath: 'assets/white_volvo_diagonal_R.png'),
          ]
        ], 'assets/parking_diagonal_preview.png', 100, OptionTypes.wide.index,
            DiagonalParking.onEnableOuterR, DiagonalParking.onDisableOuterR)
      ]),
    ], "On-Street Parking", Parking.onEnableOuterR, Parking.onDisableOuterR),
    ChoiceManager([
      Feature([
        Option([
          [OptionImage(layer: 4, imagePath: 'assets/sidewalk_extension_R.png')]
        ], 'assets/sidewalk_extension_R.png'),
      ], 0),
      Feature([
        Option([
          [
            OptionImage(layer: 7, imagePath: 'assets/trees_near_R.png'),
            OptionImage(layer: 5, imagePath: 'assets/trees_far_R.png')
          ],
        ], 'assets/trees_near_R.png', 100, OptionTypes.extra.index),
      ]),
    ], "Sidewalk", Sidewalk.onEnableR, Sidewalk.onDisableR),
  ], Lane5.onEnable, Lane5.onDisable),
  LaneNames.crosswalk: LaneManager([
    ChoiceManager([
      Feature(
        [
          Option([
            [
              OptionImage(layer: 6, imagePath: 'assets/crosswalk_L.png'),
              OptionImage(layer: 6, imagePath: 'assets/crosswalk_R.png')
            ],
            [
              OptionImage(
                  layer: 6, imagePath: 'assets/crosswalk_extended_L.png'),
              OptionImage(
                  layer: 6, imagePath: 'assets/crosswalk_extended_R.png')
            ],
          ], 'assets/crosswalk_default_preview.png'),
        ],
      ),
      Feature(
        [
          Option([
            [OptionImage(layer: 5, imagePath: 'assets/crosswalk_lines.png')]
          ], 'assets/crosswalk_lines_preview.png'),
        ],
      ),
    ], "Crosswalk", null, null, true, true),
  ], Crosswalk.onEnable, Crosswalk.onDisable),
  LaneNames.buildings: LaneManager([
    ChoiceManager([
      Feature([
        Option([
          [OptionImage(layer: 4, imagePath: 'assets/brownstone_building.png')]
        ], 'assets/brownstone_building_preview.png'),
        Option([
          [OptionImage(layer: 4, imagePath: 'assets/condo_whiteandred.png')]
        ], 'assets/condo_whiteandred_preview.png'),
      ]),
    ], "Buildings", null, null, true, true)
  ], Buildings.onEnable, Buildings.onDisable),
};
