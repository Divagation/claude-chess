export declare class AboutMenu {
    private screenGui;
    private onBackCallback?;
    constructor(onBack: () => void);
    show(): void;
    hide(): void;
    destroy(): void;
}
