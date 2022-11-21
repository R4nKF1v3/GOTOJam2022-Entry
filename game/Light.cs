using Godot;
using Godot.Collections;
using System;
using System.Collections.Generic;

[Tool]
public class Light : Node2D
{
    private bool refreshOnEditor = false;
    [Export]
    public bool RefreshOnEditor
    {
        get { return refreshOnEditor; }
        set
        {
            refreshOnEditor = value;
            if (IsInsideTree() && Engine.EditorHint && refreshOnEditor)
            {
                RefreshShadows();
                UpdateRayLengths();
            }
        }
    }

    private int shadowResolution = 1080;
    [Export]
    public int ShadowResolution
    {
        get { return shadowResolution; }
        set {
            shadowResolution = value;
            if (IsInsideTree() && (!Engine.EditorHint || (Engine.EditorHint && refreshOnEditor)))
            {
                RefreshShadows();
                UpdateRayLengths();
            }
        }
    }
    private Color lightColor;
    [Export]
    public Color LightColor
    {
        get { return lightColor; }
        set {
            lightColor = value;
            if (IsInsideTree() && (!Engine.EditorHint || (Engine.EditorHint && refreshOnEditor)))
            {
                RefreshShadows();
                UpdateRayLengths();
            }
        }
    }

    private float lightSize = 1080;
    [Export]
    public float LightSize
    {
        get { return lightSize; }
        set {
            lightSize = value;
            if (IsInsideTree() && (!Engine.EditorHint || (Engine.EditorHint && refreshOnEditor)))
            {
                RefreshShadows();
                UpdateRayLengths();
            }
        }
    }

    private RayCast2D rayCast;
    private Array<float> rayLenghts = new Array<float>();

    public override void _Ready()
    {
        rayCast = GetNode<RayCast2D>("RayCast2D");
        if (!Engine.EditorHint || refreshOnEditor)
        {
            CallDeferred("UpdateRayLengths");
        }
    }

    public override void _EnterTree()
    {
        base._EnterTree();
        RefreshShadows();
    }

    public void UpdateRayLengths()
    {
        rayCast = GetNode<RayCast2D>("RayCast2D");
        for (int i = 0; i < shadowResolution; i++)
        {
            float angle = (float)(((float) i / (float) shadowResolution) * Math.PI * 2.0f);
            rayCast.CastTo = MakePoint(angle, lightSize);
            rayCast.ForceRaycastUpdate();
            if (rayCast.IsColliding())
            {
                Vector2 collisionPos = rayCast.GetCollisionPoint() - GlobalPosition;
                float collisionLength = Vector2.Zero.DistanceTo(collisionPos);
                rayLenghts[i] = collisionLength;
            }
            else
            {
                rayLenghts[i] = lightSize;
            }
        }
        Update();
    }

    private void RefreshShadows()
    {
        rayLenghts = new Array<float>();
        for (int i = 0; i < shadowResolution; i++)
        {
            rayLenghts.Add(10f);
        }
    }

    private Vector2 MakePoint(float direction, float amount)
    {
        Vector2 result = new Vector2(0f, 0f);
        result.x += (float) Math.Cos(direction) * amount;
        result.y -= (float) Math.Sin(direction) * amount;
        return result;
    }

    public override void _Draw()
    {
        base._Draw();
        List<Vector2> points = new List<Vector2>();
        List<Color> colors = new List<Color>();
        for (int i = 0; i < shadowResolution; i++)
        {
            int indexPlus = i + 1;
            if (indexPlus == shadowResolution){indexPlus = 0;}
            float angleA = ((float)i / shadowResolution) * (float) Math.PI * 2.0f;
            float angleB = ((float)(i+1) / shadowResolution) * (float) Math.PI * 2.0f;
            float powerA = rayLenghts[i] / lightSize;
            float powerB = rayLenghts[indexPlus] / lightSize;
            points.Add(Vector2.Zero);
            points.Add(MakePoint(angleA, rayLenghts[i]));
            points.Add(MakePoint(angleB, rayLenghts[indexPlus]));
            colors.Add(lightColor);
            colors.Add(lightColor.LinearInterpolate(new Color(lightColor.r, LightColor.g, lightColor.b, 0f), powerA));
            colors.Add(lightColor.LinearInterpolate(new Color(lightColor.r, LightColor.g, lightColor.b, 0f), powerB));
        }
        DrawPolygon(points.ToArray(), colors.ToArray());
    }

}
