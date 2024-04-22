using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

[RequireComponent(typeof(Image))]
public class UIGradation : MonoBehaviour
{
    [SerializeField]
    private Shader gradationShader;

    [SerializeField]
    private Vector2 leftPos = Vector2.left;

    [SerializeField]
    private Vector2 rightPos = Vector2.right;

#if UNITY_EDITOR
    private void OnValidate()
    {
        Material mat = GetComponent<Image>().material;
        mat.shader = gradationShader;

        Vector2 dt = rightPos - leftPos;
        float rad = Mathf.Atan2(dt.y, dt.x);

        mat.SetFloat("_Rot", rad);
    }
#endif
}
