export declare class UpdatesMenu {
    private screenGui;
    private onBackCallback?;
    constructor(onBack: () => void);
    show(): void;
    hide(): void;
    destroy(): void;
}
