using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using TMPro;
public class DemoController : MonoBehaviour {


    public int demoNum = 0;
    //1.溶解效果
    //2.流光效果*
    //3.描邊*
    //4.邊緣光*
    //5.動態模糊*
    //6.鏡子效果*
    //7.玻璃效果*
    //8.Bloom效果

    public GameObject[] _Character;

    public TAShader.Bloom _bloom;
    public TAShader.MotionBlur _MotionBlur;
    public Animator _Animator;

    public TextMeshProUGUI _textMesh;

    string[] _title = {
        "1.溶解效果",
        "2.流光效果",
        "3.描邊",
        "4.邊緣光",
        "5.動態模糊",
        "6.鏡子效果",
        "7.玻璃效果",
        "8.Bloom效果"
    };

    public GameObject[] _btn;
    // Use this for initialization
    void Start () {
        //初始化關閉
        DemoInit(false);

        DemoNum(demoNum);
    }

    void DemoInit(bool boolValue)
    {
        _bloom.enabled = boolValue;
        _MotionBlur.enabled = boolValue;

        for (int i = 0; i < _Character.Length; i++)
        {
            _Character[i].SetActive(boolValue);
        }
    }

    void DemoNum(int demoNum)
    {
        if (demoNum == 0)
            return;



        if (demoNum == 1)
        {
            _btn[0].SetActive(false);
            _btn[1].SetActive(true);
        }
        else if (demoNum == _Character.Length)
        {
            _btn[0].SetActive(true);
            _btn[1].SetActive(false);
        }
        else
        {
            _btn[0].SetActive(true);
            _btn[1].SetActive(true);
        }

        int num = demoNum - 1;

        _Character[num].SetActive(true);
        _textMesh.SetText(_title[num]);



        if (num == 4)
        {
            _MotionBlur.enabled = true;
            _Animator.SetBool("isMove", true);
        }
        else
        {
            _MotionBlur.enabled = false;
            _Animator.SetBool("isMove", false);
        }

        if (num == 6)
        {
            _Animator.SetBool("isGlass", true);
        }
        else
        {
            _Animator.SetBool("isGlass", false);
        }

        if (num == 7)
        {
            _bloom.enabled = true;
        }
        else
        {
            _bloom.enabled = false;
        }
    }
    public void PreDemo()
    {
        DemoInit(false);
        demoNum -= 1;
        DemoNum(demoNum);
        Debug.Log("PreDemo" + demoNum);
    }

    public void NextDemo()
    {
        DemoInit(false);
        demoNum += 1;
        DemoNum(demoNum);
        Debug.Log("NextDemo:" + demoNum);
    }
}
