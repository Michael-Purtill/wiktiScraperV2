<script>
    import * as _ from 'lodash';
    import { onMount } from 'svelte';
    
    
    let langInfo = [];
    let selectors = [];

    onMount(async () => {
        fetch("/api/wordInfo/" + "Czech/pes").then((r) => {return r.json()}).then((d) => {langInfo = d })
    });

    function handleClick(e) {
        if (_.includes(selectors, e.target.id)) {
            selectors = _.filter(selectors, s => s != e.target.id)
        }
        else {
            let selectorsCopy = _.cloneDeep(selectors);
            if (e.target.localName == "td") {
                selectorsCopy.push(e.target.parentElement.parentElement.parentElement.id + "->" + e.target.id);
            } 
            else {
                selectorsCopy.push(e.target.id);
            }
            selectors = selectorsCopy;
        }
    }

    function handleSubmit() {
        fetch("/api/testPageJsonHandler", {
            method: "POST",
            headers: {
                'Accept': 'application/json',
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({selectors: selectors, lang: "Czech", word: "pes"})
            
         }).then((res) => console.log(res));
    }

</script>

<div>
    {#each langInfo as datum, i}
        <div>
            <h3>{datum.title.replace("[ edit ]", "").replace("[edit]", "")}</h3>
            {#each datum.content as content, j}
                {#if content.tag == "p"}
                <p id={`${i}:${j}`} on:click={handleClick}>{content.innerContent.replace("\n", "")}</p>
                {:else if content.tag == "ul" || content.tag == "ol"}
                <ul id={`${i}:${j}`} on:click={handleClick}>
                    {#each content.innerContent as innerContent}
                        <li>{innerContent.replace("\n", "")}</li>
                    {/each}
                </ul>
                {:else if content.tag="table"}
                <table id={`${i}:${j}`}>
                    <tbody>
                        {#each content.innerContent as innerContent, k}
                            <tr>
                                {#each innerContent as inner, l}
                                    <td id={`${k}:${l}`} on:click={handleClick}>{inner.replace("\n", "")}</td>
                                {/each}
                            </tr>
                        {/each}
                    </tbody>
                </table>
                {/if}
            {/each}
        </div>
    {/each}

    <button on:click={handleSubmit}>Submit</button>
</div>

<style></style>