# LeyHitreg
A GMod Hit-Registration addon from 2017

## How does it work
Normally the game sends a packet to the server saying he wants to shoot a bullet and the entire hit registration/confirmation is done serverside, while the client tries to determine whether he hit/not using his own view of the game based on his tick. However, the data of the client and the server does not always match up. Therefore, the server uses certain algorithms to roll back the state depending on how much the user lagged. This is referred to as lag compensation. The main issue is, this kind of rollback isn't perfect especially since the server does not have all data and the two are not fully synced up.

That's the issue this addon tackles. To solve this, the client additionally tells the server whether his shot was a hit and which hit group he shot. This solves the issue since the client is the one dictating whether a shot was a hit. If the client doesn't send a shot then the game just does its normal serverside HitReg. Additionally, the server has validations for checking whether the shot being sent is reasonable to avoid exploitation, such as shooting through walls.
