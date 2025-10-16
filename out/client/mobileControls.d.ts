export interface CameraControls {
    onRotateLeft: () => void;
    onRotateRight: () => void;
    onZoomIn: () => void;
    onZoomOut: () => void;
}
export declare class MobileControls {
    private screenGui;
    private controls;
    private GuiService;
    private UserInputService;
    private RunService;
    private isRotatingLeft;
    private isRotatingRight;
    private isZoomingIn;
    private isZoomingOut;
    constructor(controls: CameraControls);
    private createControls;
    private createButton;
    private setupContinuousRotation;
    private setupTouchInteractions;
    destroy(): void;
    setVisible(visible: boolean): void;
    isVisible(): boolean;
}
