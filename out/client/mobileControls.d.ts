export interface CameraControls {
    onRotateLeft: () => void;
    onRotateRight: () => void;
    onZoomIn: () => void;
    onZoomOut: () => void;
    onRotateDelta?: (delta: number) => void;
    onZoomDelta?: (delta: number) => void;
}
export declare class MobileControls {
    private controls;
    private UserInputService;
    constructor(controls: CameraControls);
    private setupTouchInteractions;
}
