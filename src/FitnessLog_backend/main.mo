import Buffer "mo:base/Buffer";
import Text "mo:base/Text";
import Time "mo:base/Time";
import Nat "mo:base/Nat";
import Float "mo:base/Float";

actor {
  type WorkoutId = Nat;
  type WorkoutType = {
    id: Nat;
    name: Text;
  };

  type Workout = {
    id: WorkoutId;
    workoutType: Nat;
    duration: Nat;  // in minutes
    intensity: Nat; // 1-5 scale
    date: Time.Time;
    notes: Text;
  };

  var workouts = Buffer.Buffer<Workout>(0);
  var workoutTypes = Buffer.Buffer<WorkoutType>(0);

  public func addWorkoutType(name: Text) : async Nat {
    let typeId = workoutTypes.size();
    let newType: WorkoutType = {
      id = typeId;
      name = name;
    };
    workoutTypes.add(newType);
    typeId
  };

  public func logWorkout(workoutType: Nat, duration: Nat, intensity: Nat, notes: Text) : async ?WorkoutId {
    if (workoutType >= workoutTypes.size() or intensity > 5) return null;
    
    let workoutId = workouts.size();
    let newWorkout: Workout = {
      id = workoutId;
      workoutType = workoutType;
      duration = duration;
      intensity = intensity;
      date = Time.now();
      notes = notes;
    };
    workouts.add(newWorkout);
    ?workoutId
  };

  public query func getWorkout(id: WorkoutId) : async ?Workout {
    if (id >= workouts.size()) return null;
    ?workouts.get(id)
  };

  public query func getWorkoutsByType(typeId: Nat) : async ?[Workout] {
    if (typeId >= workoutTypes.size()) return null;
    
    let typeWorkouts = Buffer.Buffer<Workout>(0);
    for (workout in workouts.vals()) {
      if (workout.workoutType == typeId) {
        typeWorkouts.add(workout);
      };
    };
    ?Buffer.toArray(typeWorkouts)
  };

  public query func getFitnessStatistics() : async {
    totalWorkouts: Nat;
    totalDuration: Nat;
    averageIntensity: Float;
  } {
    var totalDuration = 0;
    var totalIntensity = 0;
    let count = workouts.size();
    
    for (workout in workouts.vals()) {
      totalDuration += workout.duration;
      totalIntensity += workout.intensity;
    };
    
    {
      totalWorkouts = count;
      totalDuration = totalDuration;
      averageIntensity = if (count == 0) 0 else Float.fromInt(totalIntensity) / Float.fromInt(count);
    }
  };
}