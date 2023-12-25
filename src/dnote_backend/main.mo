import Array "mo:base/Array";
import List "mo:base/List";
import Principal "mo:base/Principal";
import HashMap "mo:base/HashMap";
import Time "mo:base/Time";
import Text "mo:base/Text";
import Nat "mo:base/Nat";
import Option "mo:base/Option";
import Bool "mo:base/Bool";
import Model "model";
actor Dnote {

  private stable var userTotal : Nat = 0;
  private stable var users : List.List<Model.User> = List.nil<Model.User>();
  private let userInfoMap : HashMap.HashMap<Principal, Model.User> = HashMap.HashMap<Principal, Model.User>(10, Principal.equal, Principal.hash);

  // init 
  system func preupgrade() {};
  system func postupgrade(){
      for(user in List.toIter(users)){
        userInfoMap.put(user.id, user);
      };
  };

  public shared ({ caller }) func join() : async(){
    assert(userInfoMap.get(caller) != null);
    var user = { id = caller;
                  joinTime = Time.now();
                  nickName = "dnote-user" # Nat.toText(List.size<Model.User>(users));
                  about = "Please describe your personal information";
                };
    ignore List.push<Model.User>(user, users);
    userInfoMap.put(user.id, user);
  };

  public shared ({ caller }) func updatePersonalInfo(nickName: Text, about: Text): async(){
    assert(userInfoMap.get(caller) != null);

    var user = List.find<Model.User>(users, func u { Principal.equal(u.id, caller) });
    switch user{
      case null {};
      case (?user) {
        user.nickName := nickname;
        user.about := about;
        userInfoMap.put(user.id, user);
      };
    };

  };

  public shared ({ caller }) func newNamespace(name: Text): async(){};
  public shared ({caller}) func updateNamespace(newName: Text, oldName: Text): async(){};
  public shared ({caller}) func namespaces(): async [Text]{[]};

  public shared ({caller}) func newLevel(name: Text, pLevel: Text, namespace: Text): async(){};
  public shared ({caller}) func updateLevelName (newName: Text,oldName: Text, pLevel: Text, namespace: Text): async(){};
  public shared ({caller}) func levels(pLevel: Text, namespace: Text): async [Text]{[]};

  public shared ({caller}) func applyAccess(id: Principal, level: Text, pLevel: Text, namespace: Text): async(){};
  public shared ({caller}) func grantAccess(id: Principal, level: Text, pLevel: Text, namespace: Text): async(){};
  public shared ({caller}) func cacelGrant(id: Principal, level: Text, pLevel: Text, namespace: Text): async(){};

  public shared ({caller}) func note(level: Text, pLevel: Text, namespace: Text, content: Text,title: Text, tag: [Text]): async (){};
  public shared ({caller}) func updateNote(id: Nat, content: Text,title: Text, tag: [Text]): async (){};
  public shared ({caller}) func notes(level:Text, pLevel: Text, namespace: Text): async(){};

  public shared ({caller}) func unlockNote(id: Nat){};
  public shared ({caller}) func unLockedNote(id: Nat){};

  public shared ({caller}) func follow(id: Principal): async(){};
  public shared ({caller}) func unFollow(id: Principal): async(){};
  public shared ({caller}) func follower(): async [Model.User]{[]};

  public shared ({caller}) func subscription(id: Principal, namespace: Text): async(){};
  public shared ({caller}) func subscriber(id: Principal, namespace: Text): async(){};
  public shared ({caller}) func isSubscriber(id: Principal, namespace: Text): async Bool{false};
  public shared ({caller}) func unSubscription(id: Principal, namespace: Text): async (){};

  public shared func searchNotes(keyword: Text): async (){};

};
