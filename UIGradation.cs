using System;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.UI;

[RequireComponent(typeof(Graphic))]
public class UIGradation : UIBehaviour, IMaterialModifier
{
    [SerializeField]
    private Vector2 leftPos = Vector2.left;

    [SerializeField]
    private Vector2 rightPos = Vector2.right;

    [NonSerialized]
    private Graphic graphic;
    public Graphic graphicProp => graphic ? graphic : graphic = GetComponent<Graphic>();

    [NonSerialized]
    private Material gradationMaterial;

    private readonly int rotPropertyId = Shader.PropertyToID("_Rot");

    private float rad;

    protected override void OnEnable()
    {
        base.OnEnable();
        if (graphicProp == null) return;
        graphicProp.SetMaterialDirty();
    }

    protected override void OnDisable()
    {
        base.OnDisable();
        if(gradationMaterial != null)
        {
            DestroyImmediate(gradationMaterial);
        }
        gradationMaterial = null;

        if(graphicProp != null)
        {
            graphicProp.SetMaterialDirty();
        }
    }

#if UNITY_EDITOR
    protected override void OnValidate()
    {
        base.OnValidate();

        if (!IsActive() || graphicProp == null)
        {
            return;
        }

        graphicProp.SetMaterialDirty();
    }
#endif

    protected override void OnDidApplyAnimationProperties()
    {
        base.OnDidApplyAnimationProperties();
        if (!IsActive() || graphicProp == null)
        {
            return;
        }

        graphicProp.SetMaterialDirty();
    }

    Material IMaterialModifier.GetModifiedMaterial(Material baseMaterial)
    {
        var isSameShader = baseMaterial.shader.name == graphicProp.material.shader.name;
        if (IsActive() == false || graphic == null || !isSameShader)
        {
            return baseMaterial;
        }

        if(gradationMaterial == null)
        {
            gradationMaterial = new Material(baseMaterial);
            gradationMaterial.hideFlags = HideFlags.HideAndDontSave;
        }

        gradationMaterial.CopyPropertiesFromMaterial(baseMaterial);

        CalcRotation();

        gradationMaterial.SetFloat(rotPropertyId, rad);
        return gradationMaterial;
    }

    private void CalcRotation()
    {
        Vector2 dt = rightPos - leftPos;
        rad = Mathf.Atan2(dt.y, dt.x);
    }
}
