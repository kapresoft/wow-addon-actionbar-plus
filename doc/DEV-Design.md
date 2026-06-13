## Design and Architecture of ActionbarPlus


### Add-On Structure

### ActionbarPlus V1
- initial version
- limited features

### ActionbarPlus V2

#### ActionbarPlus-Core
- database (ace3, profile, global)
- core namespace

### ActionbarPlus-BarsUI
- depends on core for db and other things
- buttons, buttons state
- button updates

### Folder Structure
                    
```text
ActionbarPlus-Core
  - ActionbarPlus-BarsUI
  - ActionbarPlus-OptionsUI
```

### Loading Sequence
ActionbarPlus-Core (V2)
 - ActionbarPlus-BarsUI     (Level 2)
   - register to core on module ready
   - listen to  event
 - ActionbarPlus-OptionsUI (Level 2)
   - register to c-ore on module ready
   - listen to OnReady event

Once the sub-addons are registered, then the core can fire messages, like 'ActionbarPlus-Core::OnReady'

