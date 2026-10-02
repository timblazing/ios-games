# iPad acceptance checks

Run on the iPad mini 2 with iOS 10.3.3. These checks have not been performed in the Linux build environment.

- Install the `.deb`; confirm the app icon appears and opens without a signing error.
- Confirm pure black background, seven tableau columns, stock, waste, and four foundations in both landscape orientations.
- Check corner ranks remain readable on long stacks. The tableau compresses its vertical spacing to keep every card on screen.
- Draw all 24 stock cards, recycle, and check the same draw order returns. Undo a draw and a recycle.
- Drag one card and a multi-card stack to legal and illegal destinations. Invalid drops should return without incrementing moves.
- Tap a card and then a destination, including an empty king column. Double-tap an ace or the next foundation card. Confirm covered waste and foundation cards cannot be moved.
- Move a tableau stack that exposes a face-down card. Confirm it flips, then undo and confirm it becomes face-down again.
- Start a drag and rotate, open Settings, or background the app. Confirm no card remains floating and the next touch works.
- Switch among the three card backs. Relaunch and confirm the choice and board return.
- Add a tall and a wide custom image before rebuilding. Confirm centered cropping, rounded corners, and no stretched artwork.
- Leave the app in the background for a minute. Confirm the game timer did not advance.
- Cancel New game and confirm the board is unchanged. Accept and confirm moves reset, Undo clears, and games played increments.
- Finish a game. Confirm all 52 cards are in foundations, a brief victory animation plays, time and moves appear, and board interaction stops. Start another game.
- Enable Reduce Motion in iOS Accessibility. Confirm move and victory animations are suppressed.
- Play for at least ten minutes. Check responsiveness, memory stability, and whether drag motion holds 60 FPS. This performance target is unverified until measured on the A7.
