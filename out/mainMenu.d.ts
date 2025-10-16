export declare class MainMenu {
    private screenGui;
    private onPlayCallback?;
    private aboutMenu;
    private updatesMenu;
    constructor(onPlay: () => void);
    private createButton;
    private showAbout;
    private showUpdates;
    show(): void;
    hide(): void;
    destroy(): void;
}
